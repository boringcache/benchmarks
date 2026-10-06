# grpc: baseline-20261006-rolling-10

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Bazel build with local top-level outputs plus measured cache restore/setup; output checks and post-job cache save are outside build timing

Observations: 1/3 recorded; 0 failed; 2 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | BoringCache | 1 | 2314 | 2314–2314 | 646411586 | 1 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

Missing observations:

- Sample 1, Actions Cache, Changed-source build
- Sample 1, BuildBuddy, Changed-source build

Missing completion checks: 37429914438


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Changed-source build | 4 | 2310 | 2314 | 646411586 | boringcache-check | not reported | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
