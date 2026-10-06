# gogs-moon: native-reapi-01

Question: Does Moon restore the Gogs web build on a clean worker?

Measured scope: BoringCache measures the complete managed native CLI operation, including cache setup, build and publication. The bazel-remote comparator records setup, build and shutdown separately. Output verification is excluded. This is a correctness screening, not a provider performance ranking.

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
| 1 | bazel-remote | Cold build | 0.1009854150000109 | 7.469111156000011 | 7.570096571000022 | unmeasured | unmeasured | not reported | [JSON](runs/1-bazel-remote-cold.json) |
| 1 | bazel-remote | Warm build | 0.10081523600001674 | 1.5716351439999983 | 1.672450380000015 | unmeasured | unmeasured | hit | [JSON](runs/1-bazel-remote-warm.json) |
| 1 | BoringCache | Cold build | 0 | 11.806481616 | 11.806481616 | unmeasured | unmeasured | not reported | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0 | 5.78419074 | 5.78419074 | unmeasured | unmeasured | hit | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
