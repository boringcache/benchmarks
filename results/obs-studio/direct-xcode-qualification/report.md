# obs-studio: direct-xcode-qualification

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 656.8639490000003 | 656.8639490000003–656.8639490000003 | unmeasured | 0 |
| Changed-source build | Actions Cache | 1 | 100.81440899999996 | 100.81440899999996–100.81440899999996 | unmeasured | 0 |
| Cold build | BoringCache | 1 | 658.400308 | 658.400308–658.400308 | 983997286 | 1 |
| Changed-source build | BoringCache | 1 | 193.70680499999997 | 193.70680499999997–193.70680499999997 | 985937000 | 1 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 656.8639490000003 | 656.8639490000003 | unmeasured | unmeasured | miss | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Changed-source build | 7 | 93.81440899999996 | 100.81440899999996 | unmeasured | unmeasured | hit | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Cold build | 7 | 651.400308 | 658.400308 | 983997286 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Changed-source build | 22 | 171.70680499999997 | 193.70680499999997 | 985937000 | boringcache-check | hit | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
