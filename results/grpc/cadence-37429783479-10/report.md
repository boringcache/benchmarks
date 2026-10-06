# grpc: cadence-37429783479-10

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Bazel build with local top-level outputs plus measured cache restore/setup; output checks and post-job cache save are outside build timing

Observations: 6/6 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 3207 | 3207–3207 | 163718917 | 1 |
| Warm build | Actions Cache | 1 | 85 | 85–85 | 163718917 | 1 |
| Cold build | BoringCache | 1 | 2242 | 2242–2242 | 648324459 | 1 |
| Warm build | BoringCache | 1 | 94 | 94–94 | 718161104 | 1 |
| Cold build | BuildBuddy | 1 | 2767 | 2767–2767 | unmeasured | 0 |
| Warm build | BuildBuddy | 1 | 153 | 153–153 | unmeasured | 0 |

Missing completion checks: 37429879437


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 3207 | 3207 | 163718917 | github-actions-cache-api | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 4 | 81 | 85 | 163718917 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 3 | 2239 | 2242 | 648324459 | boringcache-check | not reported | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 13 | 81 | 94 | 718161104 | boringcache-check | not reported | [JSON](runs/1-boringcache-warm.json) |
| 1 | BuildBuddy | Cold build | 0 | 2767 | 2767 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-cold.json) |
| 1 | BuildBuddy | Warm build | 0 | 153 | 153 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-warm.json) |

[Full records and checks](report.json)
