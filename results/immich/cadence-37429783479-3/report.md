# immich: cadence-37429783479-3

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed Docker build including image export and load, plus measured provider setup; output inspection is outside the timed build; provider post-job work is reported separately

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 369 | 369–369 | unmeasured | 0 |
| Warm build | Actions Cache | 1 | 53 | 53–53 | unmeasured | 0 |
| Cold build | BoringCache | 1 | 192 | 192–192 | 1757268052 | 1 |
| Warm build | BoringCache | 1 | 42 | 42–42 | 1757268052 | 1 |

Missing completion checks: 37429878473


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 11 | 358 | 369 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 6 | 47 | 53 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 0 | 192 | 192 | 1757268052 | boringcache-check | reuse not measured (2 refs planned) | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0 | 42 | 42 | 1757268052 | boringcache-check | reuse not measured (2 refs planned) | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
