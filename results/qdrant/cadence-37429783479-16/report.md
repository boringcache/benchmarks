# qdrant: cadence-37429783479-16

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 721 | 721–721 | unmeasured | 0 |
| Warm build | Actions Cache | 1 | 15 | 15–15 | unmeasured | 0 |
| Cold build | BoringCache | 1 | 590 | 590–590 | 2081619593 | 1 |
| Warm build | BoringCache | 1 | 20 | 20–20 | 2081619593 | 1 |

Missing completion checks: 37429890210


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 11 | 710 | 721 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 5 | 10 | 15 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 0 | 590 | 590 | 2081619593 | boringcache-check | reuse not measured (1 refs planned) | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0 | 20 | 20 | 2081619593 | boringcache-check | reuse not measured (1 refs planned) | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
