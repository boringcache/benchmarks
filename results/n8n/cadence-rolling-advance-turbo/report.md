# n8n: cadence-rolling-advance-turbo

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Selected workload build plus measured provider setup: Turbo excludes dependency installation; Docker includes image export and load and excludes prepared source setup. Output checks and unmeasured post-job work are reported separately

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 134 | 134–134 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | 131 | 131–131 | 96876410 | 1 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 1 | 133 | 134 | unmeasured | unmeasured | miss | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Changed-source build | 7 | 124 | 131 | 96876410 | boringcache-check | hit | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
