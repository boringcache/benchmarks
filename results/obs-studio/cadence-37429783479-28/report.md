# obs-studio: cadence-37429783479-28

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 489.82644629199996 | 489.82644629199996–489.82644629199996 | 164317276 | 1 |
| Changed-source build | Actions Cache | 1 | 41.909111835000004 | 41.909111835000004–41.909111835000004 | 164317276 | 1 |
| Cold build | BoringCache | 1 | 664.054711106 | 664.054711106–664.054711106 | 172201372 | 1 |
| Changed-source build | BoringCache | 1 | 43.520271441999995 | 43.520271441999995–43.520271441999995 | 172201372 | 1 |

Missing completion checks: 37429883504, 37429884368


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 489.82644629199996 | 489.82644629199996 | 164317276 | github-actions-cache-api | miss | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Changed-source build | 5 | 36.909111835000004 | 41.909111835000004 | 164317276 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Cold build | 3 | 661.054711106 | 664.054711106 | 172201372 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Changed-source build | 7 | 36.520271441999995 | 43.520271441999995 | 172201372 | boringcache-check | hit | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
