# hugo-go: cadence-37429783479-2

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured cache publication is reported separately

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 55 | 55–55 | unmeasured | 0 |
| Warm build | Actions Cache | 1 | 9 | 9–9 | 161786773 | 1 |
| Cold build | BoringCache | 1 | 88 | 88–88 | 589455110 | 1 |
| Warm build | BoringCache | 1 | 16 | 16–16 | 811503108 | 1 |

Missing completion checks: 37429885841


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 55 | 55 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 3 | 6 | 9 | 161786773 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 3 | 85 | 88 | 589455110 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 8 | 8 | 16 | 811503108 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
