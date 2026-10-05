# obs-studio: cadence-rolling-seed-xcode-02

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 710.543963 | 710.543963–710.543963 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | 528.281434 | 528.281434–528.281434 | 983997286 | 1 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 0 | 710.543963 | 710.543963 | unmeasured | unmeasured | miss | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Changed-source build | 5 | 523.281434 | 528.281434 | 983997286 | boringcache-check | not reported | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
