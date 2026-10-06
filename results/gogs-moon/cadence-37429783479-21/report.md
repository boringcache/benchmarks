# gogs-moon: cadence-37429783479-21

Question: Does Moon restore the Gogs web build on a clean worker?

Measured scope: Native command and registry startup after dependency preparation; registry shutdown is recorded separately. The bazel-remote store is transferred as a GitHub artifact outside timing. This screen does not compare end-to-end provider performance. Rolling runs use the same measurement boundary. Comparator cache transfer is outside build timing; rolling reuse requires retained seed and native hit evidence.

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Cold build | bazel-remote | 1 | unmeasured | 0 |
| Warm build | bazel-remote | 1 | unmeasured | 0 |
| Cold build | BoringCache | 1 | unmeasured | 0 |
| Warm build | BoringCache | 1 | unmeasured | 0 |

Comparison checks:

- This series does not declare a comparison of provider performance.

Missing completion checks: 37429883203


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | bazel-remote | Cold build | 0.10106399400000043 | 8.895031958999994 | 8.996095952999994 | unmeasured | unmeasured | not reported | [JSON](runs/1-bazel-remote-cold.json) |
| 1 | bazel-remote | Warm build | 0.10108366100001831 | 1.4724388989999966 | 1.573522560000015 | unmeasured | unmeasured | hit | [JSON](runs/1-bazel-remote-warm.json) |
| 1 | BoringCache | Cold build | 0.10109131500000501 | 9.183547685000008 | 9.284639000000013 | unmeasured | unmeasured | not reported | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0.10077801500000305 | 2.7678741490000007 | 2.868652164000004 | unmeasured | unmeasured | hit | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
