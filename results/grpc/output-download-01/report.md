# grpc: output-download-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Observations: 6/6 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 3193 | 3193–3193 | 163734007 | 1 |
| Warm build | Actions Cache | 1 | 93 | 93–93 | 163734007 | 1 |
| Cold build | BoringCache | 1 | 2107 | 2107–2107 | 647876056 | 1 |
| Warm build | BoringCache | 1 | 84 | 84–84 | 718160974 | 1 |
| Cold build | BuildBuddy | 1 | 2092 | 2092–2092 | unmeasured | 0 |
| Warm build | BuildBuddy | 1 | 122 | 122–122 | unmeasured | 0 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 1 | 3192 | 3193 | 163734007 | github-actions-cache-api | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 3 | 90 | 93 | 163734007 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 2 | 2105 | 2107 | 647876056 | boringcache-check | not reported | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 12 | 72 | 84 | 718160974 | boringcache-check | not reported | [JSON](runs/1-boringcache-warm.json) |
| 1 | BuildBuddy | Cold build | 0 | 2092 | 2092 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-cold.json) |
| 1 | BuildBuddy | Warm build | 0 | 122 | 122 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-warm.json) |

[Full records and checks](report.json)
