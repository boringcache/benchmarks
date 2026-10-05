# hugo-go: direct-dispatch-qualification

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Observations: 8/8 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 2 | 79.5 | 78–81 | unmeasured | 0 |
| Warm build | Actions Cache | 2 | 17.0 | 11–23 | 161851116.5 | 2 |
| Cold build | BoringCache | 2 | 76.0 | 72–80 | 646497724.5 | 2 |
| Warm build | BoringCache | 2 | 18.0 | 16–20 | 811503108.0 | 2 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 1 | 77 | 78 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 4 | 7 | 11 | 161849774 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 5 | 75 | 80 | 604312219 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 8 | 8 | 16 | 811503108 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |
| 2 | Actions Cache | Cold build | 0 | 81 | 81 | unmeasured | unmeasured | not reported | [JSON](runs/2-actions-cache-cold.json) |
| 2 | Actions Cache | Warm build | 2 | 21 | 23 | 161852459 | github-actions-cache-api | hit | [JSON](runs/2-actions-cache-warm.json) |
| 2 | BoringCache | Cold build | 5 | 67 | 72 | 688683230 | boringcache-check | miss | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 9 | 11 | 20 | 811503108 | boringcache-check | hit | [JSON](runs/2-boringcache-warm.json) |

[Full records and checks](report.json)
