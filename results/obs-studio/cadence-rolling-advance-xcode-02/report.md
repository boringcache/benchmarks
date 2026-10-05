# obs-studio: cadence-rolling-advance-xcode-02

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 189.99793799999998 | 189.99793799999998–189.99793799999998 | 309445116 | 1 |
| Changed-source build | BoringCache | 1 | 169.57710600000001 | 169.57710600000001–169.57710600000001 | 1004724519 | 1 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 11 | 178.99793799999998 | 189.99793799999998 | 309445116 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Changed-source build | 23 | 146.57710600000001 | 169.57710600000001 | 1004724519 | boringcache-check | not reported | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
