# obs-studio: baseline-20261006-rolling-27

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 444.513931 | 444.513931–444.513931 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | 591.4622860000001 | 591.4622860000001–591.4622860000001 | 983997286 | 1 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

Missing completion checks: 37429963857


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 1 | 443.513931 | 444.513931 | unmeasured | unmeasured | miss | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Changed-source build | 4 | 587.4622860000001 | 591.4622860000001 | 983997286 | boringcache-check | not reported | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
