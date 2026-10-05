# stackstorm-pants: registry-qualification-01

Question: Does Pants restore StackStorm pack metadata test results on a clean worker?

Measured scope: Native command and registry startup after dependency preparation; registry shutdown is recorded separately. The bazel-remote store is transferred as a GitHub artifact outside timing. This screen does not compare end-to-end provider performance.

Observations: 8/8 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Cold build | bazel-remote | 2 | unmeasured | 0 |
| Warm build | bazel-remote | 2 | unmeasured | 0 |
| Cold build | BoringCache | 2 | unmeasured | 0 |
| Warm build | BoringCache | 2 | unmeasured | 0 |

Comparison checks:

- This series does not declare a comparison of provider performance.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | bazel-remote | Cold build | 0.10090506299999902 | 18.365842974999993 | 18.46674803799999 | unmeasured | unmeasured | not reported | [JSON](runs/1-bazel-remote-cold.json) |
| 1 | bazel-remote | Warm build | 0.10122621899999729 | 13.986136833999993 | 14.08736305299999 | unmeasured | unmeasured | hit | [JSON](runs/1-bazel-remote-warm.json) |
| 1 | BoringCache | Cold build | 0.20136627799999474 | 25.576910379999987 | 25.77827665799998 | unmeasured | unmeasured | not reported | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0.20135146399999826 | 11.666110438999993 | 11.867461902999992 | unmeasured | unmeasured | hit | [JSON](runs/1-boringcache-warm.json) |
| 2 | bazel-remote | Cold build | 0.10105914099999325 | 28.80764801299999 | 28.908707153999984 | unmeasured | unmeasured | not reported | [JSON](runs/2-bazel-remote-cold.json) |
| 2 | bazel-remote | Warm build | 0.10072521000000734 | 8.28355738900001 | 8.384282599000016 | unmeasured | unmeasured | hit | [JSON](runs/2-bazel-remote-warm.json) |
| 2 | BoringCache | Cold build | 0.2014053409999974 | 27.876364369 | 28.07776971 | unmeasured | unmeasured | not reported | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 0.20145238800000698 | 13.613789486999991 | 13.815241874999998 | unmeasured | unmeasured | hit | [JSON](runs/2-boringcache-warm.json) |

[Full records and checks](report.json)
