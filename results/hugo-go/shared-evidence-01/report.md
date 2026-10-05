# hugo-go: shared-evidence-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 52 | 52–52 | unmeasured | 0 |
| Warm build | Actions Cache | 1 | 8 | 8–8 | 161840391 | 1 |
| Cold build | BoringCache | 1 | 98 | 98–98 | 588257602 | 1 |
| Warm build | BoringCache | 1 | 17 | 17–17 | 811503108 | 1 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 52 | 52 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 2 | 6 | 8 | 161840391 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 8 | 90 | 98 | 588257602 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 10 | 7 | 17 | 811503108 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
