# grpc: nativelink-r2-fresh-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Bazel build with local top-level outputs plus measured cache restore/setup; output checks and post-job cache save are outside build timing

Observations: 12/16 recorded; 0 failed; 4 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 2 | 2896.5 | 2545–3248 | 163727752.0 | 2 |
| Cold build | BoringCache | 2 | 1846.0 | 1429–2263 | 624662783.0 | 2 |
| Warm build | BoringCache | 2 | 134.0 | 128–140 | 718161090.0 | 2 |
| Cold build | BuildBuddy | 2 | 3077.0 | 2910–3244 | unmeasured | 0 |
| Cold build | NativeLink (R2) | 2 | 2755.5 | 2243–3268 | 707856617.0 | 2 |
| Warm build | Actions Cache | 1 | 140 | 140–140 | 163720971 | 1 |
| Warm build | BuildBuddy | 1 | 168 | 168–168 | unmeasured | 0 |

Comparison checks:

- NativeLink release installation was outside provider setup timing while BoringCache CLI installation was included. Retain these observations for cache correctness qualification; do not use them for a provider timing comparison. Subsequent execution definitions include NativeLink installation in setup timing.

Run 37357215892 failed completion checks:

- Workflow concluded failure
- NativeLink (R2) gRPC Bazel warm: cancelled

Run 37357216555 failed completion checks:

- Workflow concluded failure
- NativeLink (R2) gRPC Bazel warm: cancelled
- GitHub Actions gRPC Bazel warm: cancelled
- BuildBuddy gRPC Bazel warm: cancelled

Missing observations:

- Sample 1, Actions Cache, Warm build
- Sample 1, BuildBuddy, Warm build
- Sample 1, NativeLink (R2), Warm build
- Sample 2, NativeLink (R2), Warm build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 3248 | 3248 | 163734533 | github-actions-cache-api | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | BoringCache | Cold build | 2 | 2261 | 2263 | 611454284 | boringcache-check | not reported | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 12 | 116 | 128 | 718161102 | boringcache-check | not reported | [JSON](runs/1-boringcache-warm.json) |
| 1 | BuildBuddy | Cold build | 0 | 3244 | 3244 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-cold.json) |
| 1 | NativeLink (R2) | Cold build | 5 | 3263 | 3268 | 707856616 | cloudflare-r2-list-objects-v2 | miss | [JSON](runs/1-nativelink-cold.json) |
| 2 | Actions Cache | Cold build | 1 | 2544 | 2545 | 163720971 | github-actions-cache-api | not reported | [JSON](runs/2-actions-cache-cold.json) |
| 2 | Actions Cache | Warm build | 4 | 136 | 140 | 163720971 | github-actions-cache-api | hit | [JSON](runs/2-actions-cache-warm.json) |
| 2 | BoringCache | Cold build | 6 | 1423 | 1429 | 637871282 | boringcache-check | not reported | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 13 | 127 | 140 | 718161078 | boringcache-check | not reported | [JSON](runs/2-boringcache-warm.json) |
| 2 | BuildBuddy | Cold build | 0 | 2910 | 2910 | unmeasured | unmeasured | not reported | [JSON](runs/2-buildbuddy-cold.json) |
| 2 | BuildBuddy | Warm build | 0 | 168 | 168 | unmeasured | unmeasured | not reported | [JSON](runs/2-buildbuddy-warm.json) |
| 2 | NativeLink (R2) | Cold build | 5 | 2238 | 2243 | 707856618 | cloudflare-r2-list-objects-v2 | miss | [JSON](runs/2-nativelink-cold.json) |

[Full records and checks](report.json)
