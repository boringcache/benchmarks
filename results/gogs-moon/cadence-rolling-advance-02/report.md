# gogs-moon: cadence-rolling-advance-02

Question: Does Moon restore the Gogs web build on a clean worker?

Measured scope: Native command and registry startup after dependency preparation; registry shutdown is recorded separately. The bazel-remote store is transferred as a GitHub artifact outside timing. This screen does not compare end-to-end provider performance. Rolling runs use the same measurement boundary. Comparator cache transfer is outside build timing; rolling reuse requires retained seed and native hit evidence.

Observations: 1/2 recorded; 0 failed; 1 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Changed-source build | bazel-remote | 1 | unmeasured | 0 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.
- This series does not declare a comparison of provider performance.

Run 37324209639 failed completion checks:

- Workflow concluded failure
- BoringCache gogs-moon commit: failure
- gogs-moon rolling report: failure

Missing observations:

- Sample 1, BoringCache, Changed-source build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | bazel-remote | Changed-source build | 0.1011285519999916 | 8.481873947000011 | 8.583002499000003 | unmeasured | unmeasured | not reported | [JSON](runs/1-bazel-remote-commit.json) |

[Full records and checks](report.json)
