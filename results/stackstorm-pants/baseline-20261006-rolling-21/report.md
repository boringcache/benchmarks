# stackstorm-pants: baseline-20261006-rolling-21

Question: Does Pants restore StackStorm pack metadata test results on a clean worker?

Measured scope: Native command and registry startup after dependency preparation; registry shutdown is recorded separately. The bazel-remote store is transferred as a GitHub artifact outside timing. This screen does not compare end-to-end provider performance. Rolling runs use the same measurement boundary. Comparator cache transfer is outside build timing; rolling reuse requires retained seed and native hit evidence.

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Changed-source build | bazel-remote | 1 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | unmeasured | 0 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.
- This series does not declare a comparison of provider performance.

Missing completion checks: 37429945809


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | bazel-remote | Changed-source build | 0.10089661499999636 | 26.397222692 | 26.498119306999996 | unmeasured | unmeasured | not reported | [JSON](runs/1-bazel-remote-commit.json) |
| 1 | BoringCache | Changed-source build | 0.2013562050000104 | 22.136077095999994 | 22.337433301000004 | unmeasured | unmeasured | not reported | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
