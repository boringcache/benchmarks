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
