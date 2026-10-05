# grpc: nativelink-r2-rolling-seed-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Bazel build with local top-level outputs plus measured cache restore/setup; output checks and post-job cache save are outside build timing

Observations: 0/4 recorded; 0 failed; 4 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

Run 37357537232 failed completion checks:

- Workflow concluded cancelled
- NativeLink (R2) gRPC Bazel commit: cancelled
- BuildBuddy gRPC Bazel commit: cancelled
- GitHub Actions gRPC Bazel commit: cancelled
- BoringCache gRPC Bazel commit: cancelled
- gRPC Bazel rolling report: cancelled

Missing observations:

- Sample 1, BoringCache, Changed-source build
- Sample 1, Actions Cache, Changed-source build
- Sample 1, BuildBuddy, Changed-source build
- Sample 1, NativeLink (R2), Changed-source build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |

[Full records and checks](report.json)
