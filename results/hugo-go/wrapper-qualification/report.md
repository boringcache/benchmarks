# hugo-go: wrapper-qualification

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Observations: 8/8 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 2 | 85.0 | 81–89 | unmeasured | 0 |
| Warm build | Actions Cache | 2 | 11.5 | 8–15 | 161812028.0 | 2 |
| Cold build | BoringCache | 2 | 92.5 | 90–95 | 641687960.0 | 2 |
| Warm build | BoringCache | 2 | 20.0 | 18–22 | 811503108.0 | 2 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 1 | 80 | 81 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 2 | 13 | 15 | 161838514 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 5 | 85 | 90 | 675344345 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 9 | 9 | 18 | 811503108 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |
| 2 | Actions Cache | Cold build | 0 | 89 | 89 | unmeasured | unmeasured | not reported | [JSON](runs/2-actions-cache-cold.json) |
| 2 | Actions Cache | Warm build | 2 | 6 | 8 | 161785542 | github-actions-cache-api | hit | [JSON](runs/2-actions-cache-warm.json) |
| 2 | BoringCache | Cold build | 2 | 93 | 95 | 608031575 | boringcache-check | miss | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 11 | 11 | 22 | 811503108 | boringcache-check | hit | [JSON](runs/2-boringcache-warm.json) |

[Full records and checks](report.json)
