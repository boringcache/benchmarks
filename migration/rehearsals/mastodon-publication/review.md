# Source publication rehearsal result

The publisher advanced only `cadence-rehearsal-publication`. It committed intent
before making requests, retained both returned run IDs, then reconciled both
successful outcomes to `completed`. All three publication commits are verified
by GitHub. The changed paths were Mastodon's case definition and its current and
per-source rolling receipts.

- Server: [run 37322979117](https://github.com/boringcache/benchmarks/actions/runs/37322979117).
- Streaming: [run 37322983836](https://github.com/boringcache/benchmarks/actions/runs/37322983836).
- Final receipt: [commit 540010c2](https://github.com/boringcache/benchmarks/commit/540010c2).

The main branch remained at `b3855db2e9c0b27636cc143a772fe9917caf4940` throughout
this rehearsal, and `BENCHMARK_CADENCE_ACTIVE` remained unset. These are bootstrap
runs and do not establish changed-source cache reuse or comparative performance.

The local rehearsal used the operator's authenticated GitHub CLI. The separate
hosted source rehearsal exercised the read-only inspector and dry-run publisher
with the workflow token; it did not exercise main-branch write permissions.
The first activated source cycle must verify those writes and its retained
receipts. No production activation is implied by this rehearsal.

A concurrent-write check forced two publishers to read the same branch head.
The first check exposed a ref-lock race reported by GitHub as `FORBIDDEN` with
exact current and expected commit SHAs. The publisher now retries that specific
conflict as well as `STALE_DATA`, while rejecting ordinary permission failures.
The repeated check committed both independent files; one publisher encountered
and recovered from that exact conflict. The before/after responses remain beside
this review. These checks modified only the isolated rehearsal branch.
