# obs-studio: cadence-37429783479-30

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 464.00124600000004 | 464.00124600000004–464.00124600000004 | 308852053 | 1 |
| Changed-source build | Actions Cache | 1 | 155.74609799999996 | 155.74609799999996–155.74609799999996 | 308852053 | 1 |
| Cold build | BoringCache | 1 | 593.0019890000001 | 593.0019890000001–593.0019890000001 | 983997287 | 1 |
| Changed-source build | BoringCache | 1 | 191.10276499999998 | 191.10276499999998–191.10276499999998 | 985937001 | 1 |

Missing completion checks: 37429892741, 37429944787


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 464.00124600000004 | 464.00124600000004 | 308852053 | github-actions-cache-api | miss | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Changed-source build | 11 | 144.74609799999996 | 155.74609799999996 | 308852053 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Cold build | 8 | 585.0019890000001 | 593.0019890000001 | 983997287 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Changed-source build | 24 | 167.10276499999998 | 191.10276499999998 | 985937001 | boringcache-check | hit | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
