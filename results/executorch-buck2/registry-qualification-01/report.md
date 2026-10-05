# executorch-buck2: registry-qualification-01

Question: Does Buck2 restore the ExecuTorch portable runner on a clean worker?

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
| 1 | bazel-remote | Cold build | 0.10093945100001633 | 120.42167853400002 | 120.52261798500004 | unmeasured | unmeasured | not reported | [JSON](runs/1-bazel-remote-cold.json) |
| 1 | bazel-remote | Warm build | 0.10105373100000747 | 19.217436547999995 | 19.318490279000002 | unmeasured | unmeasured | hit | [JSON](runs/1-bazel-remote-warm.json) |
| 1 | BoringCache | Cold build | 0.201177897000008 | 99.75998846600001 | 99.96116636300002 | unmeasured | unmeasured | not reported | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0.2012458070000207 | 21.467698077999955 | 21.668943884999976 | unmeasured | unmeasured | hit | [JSON](runs/1-boringcache-warm.json) |
| 2 | bazel-remote | Cold build | 0.10096649500002286 | 69.55663098100001 | 69.65759747600003 | unmeasured | unmeasured | not reported | [JSON](runs/2-bazel-remote-cold.json) |
| 2 | bazel-remote | Warm build | 0.1005951120000077 | 18.738780108000014 | 18.839375220000022 | unmeasured | unmeasured | hit | [JSON](runs/2-bazel-remote-warm.json) |
| 2 | BoringCache | Cold build | 0.10093174399997906 | 153.904521489 | 154.00545323299997 | unmeasured | unmeasured | not reported | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 0.10113950999999588 | 17.465826851000003 | 17.566966361 | unmeasured | unmeasured | hit | [JSON](runs/2-boringcache-warm.json) |

[Full records and checks](report.json)
