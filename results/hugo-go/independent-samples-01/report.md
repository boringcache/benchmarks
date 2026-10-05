# hugo-go: independent-samples-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Observations: 8/8 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 2 | 70.0 | 61–79 | unmeasured | 0 |
| Warm build | Actions Cache | 2 | 9.0 | 9–9 | 161808547.0 | 2 |
| Cold build | BoringCache | 2 | 87.5 | 85–90 | 612837451.5 | 2 |
| Warm build | BoringCache | 2 | 21.0 | 18–24 | 811503108.0 | 2 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 79 | 79 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 2 | 7 | 9 | 161812772 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 5 | 80 | 85 | 610123303 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 14 | 10 | 24 | 811503108 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |
| 2 | Actions Cache | Cold build | 0 | 61 | 61 | unmeasured | unmeasured | not reported | [JSON](runs/2-actions-cache-cold.json) |
| 2 | Actions Cache | Warm build | 3 | 6 | 9 | 161804322 | github-actions-cache-api | hit | [JSON](runs/2-actions-cache-warm.json) |
| 2 | BoringCache | Cold build | 5 | 85 | 90 | 615551600 | boringcache-check | miss | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 10 | 8 | 18 | 811503108 | boringcache-check | hit | [JSON](runs/2-boringcache-warm.json) |

[Full records and checks](report.json)
