# spring-ai: cadence-37429783479-9

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured cache publication is reported separately

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 476 | 476–476 | unmeasured | 0 |
| Warm build | Actions Cache | 1 | 109 | 109–109 | 189345234 | 1 |
| Cold build | BoringCache | 1 | 391 | 391–391 | 207205555 | 1 |
| Warm build | BoringCache | 1 | 117 | 117–117 | 210696549 | 1 |

Missing completion checks: 37429881694


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 476 | 476 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 4 | 105 | 109 | 189345234 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 2 | 389 | 391 | 207205555 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 8 | 109 | 117 | 210696549 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
