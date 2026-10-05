# gogs-moon: registry-qualification-01

Question: Does Moon restore the Gogs web build on a clean worker?

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
| 1 | bazel-remote | Cold build | 0.10107650799999846 | 9.486168882000001 | 9.58724539 | unmeasured | unmeasured | miss | [JSON](runs/1-bazel-remote-cold.json) |
| 1 | bazel-remote | Warm build | 0.10098372400000244 | 1.5746930329999884 | 1.6756767569999909 | unmeasured | unmeasured | hit | [JSON](runs/1-bazel-remote-warm.json) |
| 1 | BoringCache | Cold build | 0.1007511629999982 | 5.257549611000002 | 5.358300774 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0.10086347799997952 | 2.0576024240000095 | 2.158465901999989 | unmeasured | unmeasured | hit | [JSON](runs/1-boringcache-warm.json) |
| 2 | bazel-remote | Cold build | 0.10103610000000174 | 8.49131564599999 | 8.592351745999991 | unmeasured | unmeasured | miss | [JSON](runs/2-bazel-remote-cold.json) |
| 2 | bazel-remote | Warm build | 0.1011681820000021 | 1.5704553409999917 | 1.6716235229999938 | unmeasured | unmeasured | hit | [JSON](runs/2-bazel-remote-warm.json) |
| 2 | BoringCache | Cold build | 0.20131430900005398 | 6.354287885000076 | 6.55560219400013 | unmeasured | unmeasured | miss | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 0.3019010590000022 | 2.263736571999999 | 2.5656376310000013 | unmeasured | unmeasured | hit | [JSON](runs/2-boringcache-warm.json) |

[Full records and checks](report.json)
