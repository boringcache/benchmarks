# n8n: cadence-rolling-seed-docker

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Selected workload build plus measured provider setup: Turbo excludes dependency installation; Docker includes image export and load and excludes prepared source setup. Output checks and unmeasured post-job work are reported separately

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 361 | 361–361 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | 233 | 233–233 | 483504441 | 1 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 9 | 352 | 361 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Changed-source build | 1 | 232 | 233 | 483504441 | boringcache-check | reuse not measured (2 refs planned) | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
