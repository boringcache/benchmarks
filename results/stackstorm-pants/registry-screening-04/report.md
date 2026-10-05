# stackstorm-pants: registry-screening-04

Question: Does Pants restore StackStorm pack metadata test results on a clean worker?

Measured scope: Native command and registry startup after dependency preparation; registry shutdown is recorded separately. The bazel-remote store is transferred as a GitHub artifact outside timing. This screen does not compare end-to-end provider performance.

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Cold build | bazel-remote | 1 | unmeasured | 0 |
| Warm build | bazel-remote | 1 | unmeasured | 0 |
| Cold build | BoringCache | 1 | unmeasured | 0 |
| Warm build | BoringCache | 1 | unmeasured | 0 |

Comparison checks:

- This series does not declare a comparison of provider performance.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | bazel-remote | Cold build | 0.1010307130000001 | 27.520753834999994 | 27.621784547999994 | unmeasured | unmeasured | miss | [JSON](runs/1-bazel-remote-cold.json) |
| 1 | bazel-remote | Warm build | 0.10102725400000168 | 11.179411349000006 | 11.280438603000007 | unmeasured | unmeasured | hit | [JSON](runs/1-bazel-remote-warm.json) |
| 1 | BoringCache | Cold build | 0.20137798899999382 | 26.721995090999997 | 26.92337307999999 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0.20135873500001367 | 12.511644949000015 | 12.713003684000029 | unmeasured | unmeasured | hit | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
