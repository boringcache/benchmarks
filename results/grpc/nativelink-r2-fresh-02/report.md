# grpc: nativelink-r2-fresh-02

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Bazel build with local top-level outputs plus measured cache restore/setup; output checks and post-job cache save are outside build timing

Observations: 11/16 recorded; 0 failed; 5 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 2 | 2685.5 | 2185–3186 | 163721900.0 | 2 |
| Cold build | BoringCache | 2 | 2177.5 | 2075–2280 | 617735474.5 | 2 |
| Cold build | BuildBuddy | 2 | 2466.0 | 1624–3308 | unmeasured | 0 |
| Warm build | BuildBuddy | 2 | 160.5 | 126–195 | unmeasured | 0 |
| Cold build | NativeLink (R2) | 2 | 3093.5 | 2910–3277 | 707856621.0 | 2 |
| Warm build | NativeLink (R2) | 1 | 967 | 967–967 | 707856618 | 1 |

Run 37358851818 failed completion checks:

- Workflow concluded failure
- NativeLink (R2) gRPC Bazel warm: cancelled
- BoringCache gRPC Bazel warm: cancelled
- GitHub Actions gRPC Bazel warm: cancelled

Run 37358852206 failed completion checks:

- Workflow concluded failure
- BoringCache gRPC Bazel warm: cancelled
- GitHub Actions gRPC Bazel warm: cancelled

Missing observations:

- Sample 1, BoringCache, Warm build
- Sample 1, Actions Cache, Warm build
- Sample 1, NativeLink (R2), Warm build
- Sample 2, BoringCache, Warm build
- Sample 2, Actions Cache, Warm build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 1 | 3185 | 3186 | 163727562 | github-actions-cache-api | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | BoringCache | Cold build | 4 | 2071 | 2075 | 645839548 | boringcache-check | not reported | [JSON](runs/1-boringcache-cold.json) |
| 1 | BuildBuddy | Cold build | 0 | 1624 | 1624 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-cold.json) |
| 1 | BuildBuddy | Warm build | 0 | 126 | 126 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-warm.json) |
| 1 | NativeLink (R2) | Cold build | 5 | 3272 | 3277 | 707856624 | cloudflare-r2-list-objects-v2 | miss | [JSON](runs/1-nativelink-cold.json) |
| 2 | Actions Cache | Cold build | 0 | 2185 | 2185 | 163716238 | github-actions-cache-api | not reported | [JSON](runs/2-actions-cache-cold.json) |
| 2 | BoringCache | Cold build | 4 | 2276 | 2280 | 589631401 | boringcache-check | not reported | [JSON](runs/2-boringcache-cold.json) |
| 2 | BuildBuddy | Cold build | 0 | 3308 | 3308 | unmeasured | unmeasured | not reported | [JSON](runs/2-buildbuddy-cold.json) |
| 2 | BuildBuddy | Warm build | 0 | 195 | 195 | unmeasured | unmeasured | not reported | [JSON](runs/2-buildbuddy-warm.json) |
| 2 | NativeLink (R2) | Cold build | 6 | 2904 | 2910 | 707856618 | cloudflare-r2-list-objects-v2 | miss | [JSON](runs/2-nativelink-cold.json) |
| 2 | NativeLink (R2) | Warm build | 31 | 936 | 967 | 707856618 | cloudflare-r2-list-objects-v2 | hit | [JSON](runs/2-nativelink-warm.json) |

[Full records and checks](report.json)
