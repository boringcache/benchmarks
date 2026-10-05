# opencut-moon: registry-qualification-01

Question: Does Moon restore the OpenCut web build on a clean worker?

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
| 1 | bazel-remote | Cold build | 0.10110312699998758 | 14.90259992099999 | 15.003703047999977 | unmeasured | unmeasured | miss | [JSON](runs/1-bazel-remote-cold.json) |
| 1 | bazel-remote | Warm build | 0.10098400499999372 | 11.398400035999998 | 11.499384040999992 | unmeasured | unmeasured | hit | [JSON](runs/1-bazel-remote-warm.json) |
| 1 | BoringCache | Cold build | 0.2010586919999966 | 10.875096673999998 | 11.076155365999995 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0.10103631699999482 | 11.797382260999996 | 11.89841857799999 | unmeasured | unmeasured | hit | [JSON](runs/1-boringcache-warm.json) |
| 2 | bazel-remote | Cold build | 0.1010827279999944 | 15.102131216000032 | 15.203213944000026 | unmeasured | unmeasured | miss | [JSON](runs/2-bazel-remote-cold.json) |
| 2 | bazel-remote | Warm build | 0.10110542299999992 | 10.692360459 | 10.793465882 | unmeasured | unmeasured | hit | [JSON](runs/2-bazel-remote-warm.json) |
| 2 | BoringCache | Cold build | 0.20128874499999938 | 14.586881934000004 | 14.788170679000004 | unmeasured | unmeasured | miss | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 0.10085053600001004 | 11.697542224000003 | 11.798392760000013 | unmeasured | unmeasured | hit | [JSON](runs/2-boringcache-warm.json) |

[Full records and checks](report.json)
