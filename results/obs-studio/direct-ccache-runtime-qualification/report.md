# obs-studio: direct-ccache-runtime-qualification

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 486.020332187 | 486.020332187–486.020332187 | unmeasured | 0 |
| Changed-source build | Actions Cache | 1 | 37.84547679900001 | 37.84547679900001–37.84547679900001 | unmeasured | 0 |
| Cold build | BoringCache | 1 | 489.142139402 | 489.142139402–489.142139402 | 172198996 | 1 |
| Changed-source build | BoringCache | 1 | 39.12283147599999 | 39.12283147599999–39.12283147599999 | 172198996 | 1 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 486.020332187 | 486.020332187 | unmeasured | unmeasured | miss | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Changed-source build | 2 | 35.84547679900001 | 37.84547679900001 | unmeasured | unmeasured | hit | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Cold build | 5 | 484.142139402 | 489.142139402 | 172198996 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Changed-source build | 9 | 30.122831475999988 | 39.12283147599999 | 172198996 | boringcache-check | hit | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
