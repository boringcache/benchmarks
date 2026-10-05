# grpc: local-outputs-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Bazel build with local top-level outputs plus measured cache restore/setup; output checks and post-job cache save are outside build timing

Observations: 6/6 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 3237 | 3237–3237 | 163735443 | 1 |
| Warm build | Actions Cache | 1 | 71 | 71–71 | 163735443 | 1 |
| Cold build | BoringCache | 1 | 2245 | 2245–2245 | 642012320 | 1 |
| Warm build | BoringCache | 1 | 109 | 109–109 | 718160920 | 1 |
| Cold build | BuildBuddy | 1 | 3273 | 3273–3273 | unmeasured | 0 |
| Warm build | BuildBuddy | 1 | 121 | 121–121 | unmeasured | 0 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 1 | 3236 | 3237 | 163735443 | github-actions-cache-api | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 5 | 66 | 71 | 163735443 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 3 | 2242 | 2245 | 642012320 | boringcache-check | not reported | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 33 | 76 | 109 | 718160920 | boringcache-check | not reported | [JSON](runs/1-boringcache-warm.json) |
| 1 | BuildBuddy | Cold build | 0 | 3273 | 3273 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-cold.json) |
| 1 | BuildBuddy | Warm build | 0 | 121 | 121 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-warm.json) |

[Full records and checks](report.json)
