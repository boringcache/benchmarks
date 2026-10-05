# deno: rolling-seed-compiler-only-01

Question: Does the pinned workload produce verified output and reuse its declared cache?

Measured scope: The two BoringCache Cargo release operations, including restore, build, and any permitted publication. Fresh changed-source consumers use restore-only trust; rolling jobs permit publication to the declared cohort. Output verification and unrelated setup are excluded. This is a correctness proof, not a provider timing comparison.

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Cold build | BoringCache | 1 | 1998300801 | 1 |
| Changed-source build | BoringCache | 1 | 1998300801 | 1 |

Comparison checks:

- This series does not declare a comparison of provider performance.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 0 | 3272 | 3272 | 1998300801 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Changed-source build | 0 | 2061 | 2061 | 1998300801 | boringcache-check | hit | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
