# msgpack-sbt: registry-qualification-01

Question: Does sbt reuse MessagePack compilation and test results on a clean worker?

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
| 1 | bazel-remote | Cold build | 0.10110575599992444 | 25.996618488999957 | 26.09772424499988 | unmeasured | unmeasured | miss | [JSON](runs/1-bazel-remote-cold.json) |
| 1 | bazel-remote | Warm build | 0.1006594659999962 | 14.459391225999994 | 14.56005069199999 | unmeasured | unmeasured | hit | [JSON](runs/1-bazel-remote-warm.json) |
| 1 | BoringCache | Cold build | 0.10094350800000029 | 38.32947641700002 | 38.430419925000024 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0.2015287419999936 | 24.885599751 | 25.087128492999994 | unmeasured | unmeasured | hit | [JSON](runs/1-boringcache-warm.json) |
| 2 | bazel-remote | Cold build | 0.10107761800000503 | 39.63239714100001 | 39.73347475900002 | unmeasured | unmeasured | miss | [JSON](runs/2-bazel-remote-cold.json) |
| 2 | bazel-remote | Warm build | 0.10077569999998559 | 23.176340411000012 | 23.277116110999998 | unmeasured | unmeasured | hit | [JSON](runs/2-bazel-remote-warm.json) |
| 2 | BoringCache | Cold build | 0.2013913069999944 | 38.50265927199999 | 38.70405057899998 | unmeasured | unmeasured | miss | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 0.1009555320000004 | 23.221232052000005 | 23.322187584000005 | unmeasured | unmeasured | hit | [JSON](runs/2-boringcache-warm.json) |

[Full records and checks](report.json)
