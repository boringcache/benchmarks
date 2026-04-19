# Performance Learning Log

This file is the durable engineering log for benchmark regressions and cache
stability learnings. Keep entries factual and tied to concrete runs/commits.

## 2026-04-08: gRPC and Zed launch-blocking regression

### What happened

- gRPC BoringCache regressed from roughly `1h02m` to `3h30m` in a completed run:
  - `24017136073` (2026-04-06): `1h 02m 06s`
  - `24105247054` (2026-04-07/08): `3h 30m 52s`
- Zed BoringCache remained much slower than Actions Cache:
  - Actions Cache `24062387167`: `2h 50m 10s`
  - BoringCache `24105246882`: `4h 37m 18s`

### Primary root cause (confirmed)

CLI shutdown publish behavior could accept `pending_publish` too early for cache
registry root tag flushes.

- Path:
  - `flush_pending_on_shutdown` -> `flush_kv_index_on_shutdown`
  - `confirm_kv_flush` accepted pending when `shutdown_requested=true`
  - shutdown then waited for tag visibility, but alias tags could not converge
    because root publish had not reached terminal published state yet
- Net effect:
  - proxy exits before publish convergence
  - next runner restores from missing/empty remote tag
  - warm/stale phases collapse toward cold behavior

### Fix shipped

- Repo: `boringcache/cli`
- Commit: `501226a791deb9e5571db5f64c32577517b1245a`
- Change:
  - shutdown flush confirm path now uses strict publish confirm
    (does not early-accept pending)
  - normal path keeps shutdown-aware pending acceptance behavior
  - added regression test:
    - `shutdown_confirm_waits_for_pending_publish_completion`

### Secondary amplifier (not the root cause)

gRPC benchmark workflow drift removed or weakened high-impact Bazel/networking
knobs in earlier changes, which amplified runtime cost once cache reuse collapsed.
This should be tracked separately from the publish-correctness bug.

## Guardrails by Surface

### CLI (source of truth)

- Shutdown flush must prioritize publish correctness over fast exit.
- Never treat root-tag pending publish as "good enough" for shutdown success.
- Any change to publish/confirm semantics must include:
  - normal-mode pending behavior test
  - shutdown-mode pending behavior test
  - alias-tag convergence behavior test

### actions/one (GHA orchestration only)

- Keep one opinionated, but do not hide product tuning knobs that can silently
  change benchmark claims.
- If Bazel defaults or proxy startup behavior changes, run A/B in benchmark-grpc
  before merging and record run IDs in PR notes.

### web

- Preserve clear server-owned pending-publish state contracts.
- Keep pending/published terminal behavior observable (status endpoints and logs)
  so CLI can make deterministic shutdown decisions.

### benchmark repos

- Workflows should orchestrate, not patch product internals.
- Scenario patches are allowed only for workload-shape changes (`stale-*`), not
  product behavior overrides.
- Any benchmark-only workaround (for example upstream dependency mirror fallback)
  must be documented with reason + removal condition.

## PR Checklist for Performance-Sensitive Changes

- Does this change alter cache correctness, not just speed?
- Could this change reduce cross-run warm restore reliability?
- Are defaults consistent across CLI, one, and benchmark workflows?
- Did we validate at least one real isolated-run benchmark (different runners)?
- Did we record run IDs and outcome in this log?

## 2026-04-09: `one` setup verification regression + gRPC workflow drift

### What happened

- Benchmark seed jobs started failing immediately in multiple repos after `one`
  tag `v1` moved to `v1.12.32`:
  - Hugo BC `24175323739` (failed)
  - Immich BC `24175326645` (failed)
  - Mastodon BC `24175329443` (failed)
  - PostHog BC `24175337902` (failed)
- Failure shape was identical:
  - step: `Configure boringcache/one for Docker`
  - error: timed out waiting for fresh run-scoped tags to exist before build

### Root cause (confirmed)

In `boringcache/one` docker setup mode (`mode: docker`, `docker-command: setup`),
verification classification treated registry tags as immediate-verify tags.

- With `verify=wait` default, restore step ran `boringcache check` before any
  build/export happened, so new run-scoped tags could never pass.
- This is orchestration correctness, not a product cache-miss condition.

### Fix shipped

- Repo: `boringcache/one`
- Commit: `c5084f3ee4f536370e24001bcc62a48e0cf1a2dc`
- Release: `v1.12.33` (and `v1` moved to this commit)
- Change:
  - Docker mode tags are now save-expected in write-capable runs, so setup mode
    defers verification to post-save timing.
  - Added regression coverage in `tests/product-modes.test.ts` to assert no
    pre-build `boringcache check` in setup-only mode.

### gRPC benchmark regression signal (workflow-side)

- Faster BC run (commit `95673b4`): `24121998413`
  - `cold=2215s, warm1=53s, warm2=78s, stale_low=44s, stale_mid=90s, stale_high=953s`
- Slower BC runs (commit `85b8b25`): `24128606876`, `24170305015`
  - `24128606876`: `cold=2196s, warm1=135s, warm2=189s, stale_high=1304s`
  - `24170305015`: `cold=1678s, warm1=127s, warm2=276s, stale_high=1322s`
- Key workflow delta in `85b8b25`:
  - removed gRPC tuning overrides (proxy/CLI concurrency + Bazel rc tuning)
  - moved to simplified defaults
  - net result: materially slower warm/stale behavior in benchmark runs

### Guardrail update

- `one` default verification must distinguish setup/orchestration phases from
  states that are expected to exist pre-build.
- Benchmark workflow simplification must be validated against previous run
  baselines before merge; record before/after phase deltas in this log.

## 2026-04-09: Bazel sync-write default moved into product path (`one`)

### What changed

- Repo: `boringcache/one`
- Commit: `76e0769e186ede367cd61695fc9428845ac4838e`
- Release: `v1.12.34` (`v1` moved to this commit)
- Behavior:
  - Bazel mode now writes `build --remote_cache_async=false` by default in
    generated `.bazelrc`.
  - Existing defaults kept:
    - `build --remote_download_minimal`
    - `build --remote_max_connections=64` (adaptive override still available via
      `BORINGCACHE_BAZEL_REMOTE_MAX_CONNECTIONS`)

### Why

- gRPC regressions showed workflow-only tuning was brittle and drift-prone.
- Sync write behavior should be a product default for deterministic seed-to-warm
  handoff in isolated-runner CI benchmarks, not a benchmark workflow patch.

### Guardrail update

- For Bazel integrations, do not rely on workflow-only `bazelrc-lines` for core
  remote cache correctness defaults.
- Keep workflow knobs for experiment-specific A/B only; product path should be
  launch-safe without benchmark-local tuning.

## 2026-04-16: latest benchmark baseline and PostHog warm miss

### Latest artifact-backed baseline

Use these as investigation baselines only. Several lanes were still failing or
running when the first pass was collected, and rolling artifacts before the
workflow alignment pass still include old warm/layer semantics.

Fresh, same-ref or latest paired numbers:

| Benchmark | Ref | AC cold | BC cold | AC warm | BC warm | AC layer | BC layer | AC storage MiB | BC storage MiB |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Hugo | `9a5c7e0` | 245 | 210 | 3 | 4 | 170 | 51 | 15611 | 1303 |
| Immich | `fce220b` | 1266 | 949 | 2 | 3 | 764 | 157 | 30812 | 4201 |
| PostHog | `f974d78` | 1404 | 792 | 7 | 234 | 349 | 185 | 31475 | 11162 |
| n8n | `fb2bc1c` | 328 | 323 | 45 | 46 | n/a | n/a | 652 | 669 |
| Spring AI | `de8ad9c` | 320 | 251 | 24 | 20 | n/a | n/a | 990 | 985 |
| OTel Java | `ca41b47` | 680 | 673 | 37 | 43 | n/a | n/a | 815 | 766 |
| Zed | `fdd81d0` | 2989 | 2928 | 1017 | 1032 | n/a | n/a | 2835 | 709 |
| gRPC | `b741b09` | 1665 | 1960 | 15 | 34 | n/a | n/a | 362 | 0 |

### PostHog warm investigation

- Latest same-ref PostHog fresh run:
  - BC `24528944310`
  - AC `24528944287`
- BC cold and layer-miss were good, but warm was bad:
  - BC `cold=792s, warm=234s, layer_miss=185s`
  - AC `cold=1404s, warm=7s, layer_miss=349s`
- Warm-step log showed the BC scenario build used different Docker build args
  than the seed build. The seed passed `BORINGCACHE_ALLOW_EXTERNAL_SYMLINKS=1`;
  the scenario build omitted it.
- Consequences observed in the warm log:
  - BuildKit layer keys diverged from the seed for PostHog stages that declare
    that ARG.
  - `posthog-pnpm-plugin` restore emitted `Symlink target escapes restore root`,
    so pnpm work re-ran instead of using the seeded internal cache.
	  - Several steps that should have been cached ran again, including plugin
	    transpiler, frontend build, staticfiles, and final image copy/layer replay.
- Latest completed PostHog rolling pair checked on 2026-04-16:
  - Ref `b450a351b95844b65cc63b93cfd7c06de0a77f2d`
  - BC `24532463576`: first build `1140s`, storage `15714.93 MiB`
  - AC `24532462652`: first build `525s`, storage `30515.64 MiB`
  - New fresh and rolling runs on ref `e3870d9f53d33b0a296b5b28c7d46ce61fadfaa3`
    were still in progress when checked at 2026-04-16 21:00 UTC.

### gRPC startup/storage investigation

- Latest gRPC BoringCache benchmark runs failed before producing trustworthy
  comparison artifacts:
  - BC rolling `24529360104` failed after proxy readiness timeout.
  - BC fresh `24529354640` failed similarly in the warm scenario.
- Failure log showed full-tag hydration loaded about `16.5k` entries and
  `~738 MiB`, finished with only `4` blob failures, then never produced the
  proxy ready marker within `300000ms`.
- Storage `0 MiB` was also invalid: diagnostics showed `boringcache check`
  had no token, but the size script suppressed the error and emitted `0`.

### gRPC warm comparison investigation

- Latest completed same-ref gRPC fresh pair checked on 2026-04-16:
  - Ref `b741b09494bf65c4ad9489a33534567cf4bdab4a`
  - BC `24517779632`: `cold=2380s`, `warm1=47s`, storage `0 MiB`
  - AC `24515175901`: `cold=1665s`, `warm1=15s`, storage `362 MiB`
- The detailed BC warm log from `24515175973` showed the target was not slow
  because it rebuilt. Bazel reported `3207 remote cache hit`, `2414 internal`,
  and only `2 processwrapper-sandbox` actions, with elapsed time `32.528s`.
- AC warm restored the whole Bazel output root via `actions/cache`. Bazel then
  reported `5631 action cache hit` and only `1 internal` action, with elapsed
  time `13.462s`.
- Root cause: the workflows were comparing different cache surfaces. BC used a
  pure remote Bazel proxy, while AC restored Bazel local output-root state. The
  fair fastest BC path is hybrid: `boringcache/one` Bazel mode plus an explicit
  BoringCache archive entry for `BAZEL_OUTPUT_USER_ROOT`.

### Guardrail update

- Docker benchmark seed and scenario build invocations must pass identical
  build args unless the scenario intentionally mutates that dimension.
- For PostHog, re-run fresh BC/AC after the arg-alignment fix before using any
  warm number.
- Treat gRPC as invalid until BoringCache storage no longer reports `0 MiB` and
  the Bazel tag/probe path is confirmed.
- gRPC storage probes must use the restore token path. A missing token in
  `boringcache check` should fail the benchmark instead of reporting `0 MiB`.
- Registry proxy startup warm is a readiness gate, but best-effort mode must not
  turn a small number of blob prefetch failures into a permanent warmup timeout.
  Strict cache mode can still fail lossless startup warm.
- For Bazel benchmarks, compare the same cache surface on both sides. If AC
  restores `BAZEL_OUTPUT_USER_ROOT`, BC should restore/save that output root as
  a BoringCache archive entry and keep the remote proxy as fallback. Include
  both the proxy tag and output-root archive tag in storage probes.
- `boringcache/one` must honor `fail-on-cache-miss` for generic archive
  restores. Benchmark workflows that depend on a seeded local archive should
  also keep a direct restored-path sanity check so they cannot silently fall
  back to proxy-only behavior.
