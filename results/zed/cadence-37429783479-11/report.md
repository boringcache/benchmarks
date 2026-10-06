# zed: cadence-37429783479-11

Question: Does the pinned workload produce verified output and reuse its declared cache?

Measured scope: The BoringCache Cargo operations, including their restore, build, and publication; output verification and unrelated setup are excluded. The layer proof uses a combined cold seed for each restore-only variant and makes no provider timing comparison.

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Cold build | BoringCache | 1 | 8997988095 | 1 |
| Changed-source build | BoringCache | 1 | 8997988095 | 1 |

Comparison checks:

- This series does not declare a comparison of provider performance.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 0 | 4846 | 4846 | 8997988095 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Changed-source build | 0 | 3652 | 3652 | 8997988095 | boringcache-check | hit | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
