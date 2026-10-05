# executorch-buck2: cadence-rolling-seed

Question: Does Buck2 restore the ExecuTorch portable runner on a clean worker?

Measured scope: Native command and registry startup after dependency preparation; registry shutdown is recorded separately. The bazel-remote store is transferred as a GitHub artifact outside timing. This screen does not compare end-to-end provider performance. Rolling runs use the same measurement boundary. Comparator cache transfer is outside build timing; rolling reuse requires retained seed and native hit evidence.

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Changed-source build | bazel-remote | 1 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | unmeasured | 0 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.
- This series does not declare a comparison of provider performance.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | bazel-remote | Changed-source build | 0.10102946500001053 | 163.48988875000003 | 163.59091821500004 | unmeasured | unmeasured | not reported | [JSON](runs/1-bazel-remote-commit.json) |
| 1 | BoringCache | Changed-source build | 0.20142720100000133 | 127.76391611900004 | 127.96534332000004 | unmeasured | unmeasured | not reported | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
