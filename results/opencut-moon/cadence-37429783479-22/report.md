# opencut-moon: cadence-37429783479-22

Question: Does Moon restore the OpenCut web build on a clean worker?

Measured scope: Native command and registry startup after dependency preparation; registry shutdown is recorded separately. The bazel-remote store is transferred as a GitHub artifact outside timing. This screen does not compare end-to-end provider performance. Rolling runs use the same measurement boundary. Comparator cache transfer is outside build timing; rolling reuse requires retained seed and native hit evidence.

Observations: 0/4 recorded; 0 failed; 4 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |

Comparison checks:

- This series does not declare a comparison of provider performance.

Missing observations:

- Sample 1, BoringCache, Cold build
- Sample 1, bazel-remote, Cold build
- Sample 1, BoringCache, Warm build
- Sample 1, bazel-remote, Warm build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |

[Full records and checks](report.json)
