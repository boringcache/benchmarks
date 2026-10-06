# grpc: cadence-37429783479-10

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Bazel build with local top-level outputs plus measured cache restore/setup; output checks and post-job cache save are outside build timing

Observations: 0/6 recorded; 0 failed; 6 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |

Missing observations:

- Sample 1, BoringCache, Cold build
- Sample 1, Actions Cache, Cold build
- Sample 1, BuildBuddy, Cold build
- Sample 1, BoringCache, Warm build
- Sample 1, Actions Cache, Warm build
- Sample 1, BuildBuddy, Warm build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |

[Full records and checks](report.json)
