# grpc: fresh-canary-repair-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Observations: 5/6 recorded; 0 failed; 1 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 3281 | 3281–3281 | 163728649 | 1 |
| Warm build | Actions Cache | 1 | 72 | 72–72 | 163728649 | 1 |
| Cold build | BoringCache | 1 | 2144 | 2144–2144 | 632637546 | 1 |
| Cold build | BuildBuddy | 1 | 2152 | 2152–2152 | unmeasured | 0 |
| Warm build | BuildBuddy | 1 | 135 | 135–135 | unmeasured | 0 |

Run 37288249894 failed completion checks:

- Workflow concluded failure
- BoringCache gRPC Bazel warm: failure

Missing observations:

- Sample 1, BoringCache, Warm build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 3281 | 3281 | 163728649 | github-actions-cache-api | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 4 | 68 | 72 | 163728649 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 1 | 2143 | 2144 | 632637546 | boringcache-check | not reported | [JSON](runs/1-boringcache-cold.json) |
| 1 | BuildBuddy | Cold build | 0 | 2152 | 2152 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-cold.json) |
| 1 | BuildBuddy | Warm build | 0 | 135 | 135 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-warm.json) |

[Full records and checks](report.json)
