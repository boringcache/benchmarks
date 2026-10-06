# msgpack-sbt: cadence-37429783479-25

Question: Does sbt reuse MessagePack compilation and test results on a clean worker?

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

Missing completion checks: 37429883799


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | bazel-remote | Cold build | 0.10101705799996807 | 38.315918904 | 38.41693596199997 | unmeasured | unmeasured | not reported | [JSON](runs/1-bazel-remote-cold.json) |
| 1 | bazel-remote | Warm build | 0.10100957999998172 | 20.783216046000007 | 20.88422562599999 | unmeasured | unmeasured | hit | [JSON](runs/1-bazel-remote-warm.json) |
| 1 | BoringCache | Cold build | 0.10094367700000362 | 39.007636006 | 39.108579683 | unmeasured | unmeasured | not reported | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0.20134274700001242 | 23.22745209499999 | 23.428794842000002 | unmeasured | unmeasured | hit | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
