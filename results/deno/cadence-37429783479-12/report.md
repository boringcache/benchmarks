# deno: cadence-37429783479-12

Question: Does the pinned workload produce verified output and reuse its declared cache?

Measured scope: The two BoringCache Cargo release operations, including restore, build, and any permitted publication. Fresh changed-source consumers use restore-only trust; rolling jobs permit publication to the declared cohort. Output verification and unrelated setup are excluded. This is a correctness proof, not a provider timing comparison.

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Cold build | BoringCache | 1 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | unmeasured | 0 |

Comparison checks:

- This series does not declare a comparison of provider performance.

Missing completion checks: 37429948888


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 0 | 3476 | 3476 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Changed-source build | 0 | 2598 | 2598 | unmeasured | unmeasured | hit | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
