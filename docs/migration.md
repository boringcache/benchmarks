# Benchmark repository

`boringcache/benchmarks` owns the scheduled cases, product configuration, execution
workflows, reports and monitoring. Retired execution repositories are archived.
The Docker corpus and deferred forks remain outside the scheduled suite.

The experimental measurements and rolling receipts were discarded on 2026-10-06.
The new baseline is defined in [`config/baseline.json`](../config/baseline.json).
Current measurements live in [`data/latest/current.json`](../data/latest/current.json).
The feed is empty until new runs produce verified measurements.

Scheduling is paused during cache reset, seed builds and identical-source replay.
Each rolling cache scope stays fixed when the harness or source changes. A source
update waits for its preceding observation. Failed or uncertain seed requests
require review before another dispatch. See [the cadence contract](cadence.md).

Repository and deferred-fork inventories remain in `migration/repositories.json`,
`migration/forks.json` and `migration/candidates.json`.
