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
