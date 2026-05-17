# Benchmark Learning Log

This file is for durable benchmark and cache-behavior lessons only. It is not a
run diary. Keep entries short: root cause, shipped fix, and the guardrail we
want future changes to preserve.

Current reporting standard:

- `data/latest/index.json` reports the latest complete same-commit AC/BC pair
  for each benchmark lane.
- `data/latest/windows.json` carries the rolling 3-pair summary.
- `data/latest/pairs.json` carries commit-level pair evidence.
- `data/latest/health.json` carries per-lane flow health.
- `data/snapshot/` is the pinned public-site feed.

## Active Guardrails

- Compare the same cache surface on both sides. If `actions/cache` restores a
  local output root, BoringCache must restore/save the comparable local archive
  as well as any remote proxy tag.
- Fresh Docker seed and rerun builds must use identical build args unless the
  benchmark is explicitly testing argument changes.
- Rolling cache-bootstrap samples are diagnostic only. They should populate the
  next run, not become parity claims.
- Storage probes must fail closed. Missing credentials or unreadable storage
  should never become `0 B` or false savings.
- Product defaults belong in `boringcache/one` or the CLI. Benchmark workflows
  can exercise a scenario, but should not carry hidden product correctness
  patches.
- Publish and shutdown paths must wait for terminal cache-root visibility when a
  later run depends on that root.

## Resolved Lessons

### 2026-04-08: Shutdown publish could exit before root visibility

CLI shutdown accepted `pending_publish` too early for cache registry root tags,
so a later isolated runner could restore from a missing or empty remote tag.

Fix shipped in `boringcache/cli` commit
`501226a791deb9e5571db5f64c32577517b1245a`: shutdown confirmation now waits
for strict publish completion. Keep regression coverage around normal pending
behavior, shutdown pending behavior, and alias/root convergence.

### 2026-04-09: Docker setup verification checked tags too early

`boringcache/one` Docker setup mode treated fresh run-scoped tags as if they
should exist before the build/export step, which made seed jobs fail before any
cache could be written.

Fix shipped in `boringcache/one` commit
`c5084f3ee4f536370e24001bcc62a48e0cf1a2dc` and release `v1.12.33`: setup-only
Docker tags are save-expected, so verification happens after save.

### 2026-04-09: Bazel sync-write default belongs in product config

gRPC regressions showed that workflow-only Bazel tuning was too easy to drift.

Fix shipped in `boringcache/one` commit
`76e0769e186ede367cd61695fc9428845ac4838e`: Bazel mode writes
`build --remote_cache_async=false` by default. Keep core cache correctness
defaults in product config, not benchmark-local `bazelrc` patches.

### 2026-04-16: PostHog warm rerun used different build args

The PostHog cold build passed `BORINGCACHE_ALLOW_EXTERNAL_SYMLINKS=1`; the warm
scenario omitted it. That changed Docker layer keys and made the warm rerun look
like a cache miss.

Guardrail: benchmark seed and scenario invocations must keep build args aligned
unless the scenario intentionally mutates that dimension.

### 2026-04-16: gRPC compared different cache surfaces

The gRPC comparison mixed a pure BoringCache remote Bazel proxy path against an
`actions/cache` local Bazel output-root restore. Storage also reported invalid
`0 B` values when the probe lacked the right token.

Guardrail: compare equivalent local/remote surfaces and fail storage probes
closed when credentials or diagnostics are missing.
