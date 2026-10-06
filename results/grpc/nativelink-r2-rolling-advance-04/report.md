# grpc: nativelink-r2-rolling-advance-04

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Bazel build with local top-level outputs plus measured cache restore/setup; output checks and post-job cache save are outside build timing

Observations: 3/4 recorded; 0 failed; 1 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 89 | 89–89 | 178632079 | 1 |
| Changed-source build | BuildBuddy | 1 | 180 | 180–180 | unmeasured | 0 |
| Changed-source build | NativeLink (R2) | 1 | 970 | 970–970 | 756897941 | 1 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

Run 37365008673 failed completion checks:

- Workflow concluded failure
- BoringCache gRPC Bazel commit: cancelled
- NativeLink (R2) gRPC Bazel commit: cancelled

Missing observations:

- Sample 1, BoringCache, Changed-source build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 4 | 85 | 89 | 178632079 | github-actions-cache-api | miss | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BuildBuddy | Changed-source build | 0 | 180 | 180 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-commit.json) |
| 1 | NativeLink (R2) | Changed-source build | 8 | 962 | 970 | 756897941 | cloudflare-r2-list-objects-v2 | hit | [JSON](runs/1-nativelink-commit.json) |

[Full records and checks](report.json)
