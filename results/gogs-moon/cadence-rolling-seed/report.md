# gogs-moon: cadence-rolling-seed

Question: Does Moon restore the Gogs web build on a clean worker?

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
| 1 | bazel-remote | Changed-source build | 0.10112419299997555 | 9.287674577000018 | 9.388798769999994 | unmeasured | unmeasured | not reported | [JSON](runs/1-bazel-remote-commit.json) |
| 1 | BoringCache | Changed-source build | 0.10093500900000407 | 8.487470181999996 | 8.588405191 | unmeasured | unmeasured | not reported | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
