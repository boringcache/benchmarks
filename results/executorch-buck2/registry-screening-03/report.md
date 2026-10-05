# executorch-buck2: registry-screening-03

Question: Does Buck2 restore the ExecuTorch portable runner on a clean worker?

Measured scope: Native command and registry startup after dependency preparation; registry shutdown is recorded separately. The bazel-remote store is transferred as a GitHub artifact outside timing. This screen does not compare end-to-end provider performance.

Observations: 1/4 recorded; 0 failed; 3 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Cold build | BoringCache | 1 | unmeasured | 0 |

Comparison checks:

- This series does not declare a comparison of provider performance.

Run 37302678892 failed completion checks:

- Workflow concluded failure
- bazel-remote executorch-buck2 cold: failure

Missing observations:

- Sample 1, bazel-remote, Cold build
- Sample 1, BoringCache, Warm build
- Sample 1, bazel-remote, Warm build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 0.20137542499998062 | 154.453031812 | 154.654407237 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |

[Full records and checks](report.json)
