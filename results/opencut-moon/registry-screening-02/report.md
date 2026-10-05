# opencut-moon: registry-screening-02

Question: Does Moon restore the OpenCut web build on a clean worker?

Measured scope: Native command and registry startup after dependency preparation; registry shutdown is recorded separately. The bazel-remote store is transferred as a GitHub artifact outside timing. This screen does not compare end-to-end provider performance.

Observations: 3/4 recorded; 0 failed; 1 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Cold build | bazel-remote | 1 | unmeasured | 0 |
| Warm build | bazel-remote | 1 | unmeasured | 0 |
| Cold build | BoringCache | 1 | unmeasured | 0 |

Comparison checks:

- This series does not declare a comparison of provider performance.

Run 37302001164 failed completion checks:

- Workflow concluded failure
- boringcache opencut-moon warm: failure

Missing observations:

- Sample 1, BoringCache, Warm build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | bazel-remote | Cold build | 0.1011117870000362 | 15.10769691400003 | 15.208808701000066 | unmeasured | unmeasured | miss | [JSON](runs/1-bazel-remote-cold.json) |
| 1 | bazel-remote | Warm build | 0.10103412799998068 | 10.993322974999984 | 11.094357102999965 | unmeasured | unmeasured | hit | [JSON](runs/1-bazel-remote-warm.json) |
| 1 | BoringCache | Cold build | 0.1008831449999974 | 14.597016275000009 | 14.697899420000006 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |

[Full records and checks](report.json)
