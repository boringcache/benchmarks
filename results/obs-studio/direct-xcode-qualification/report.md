# obs-studio: direct-xcode-qualification

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Status: all declared observations collected; 0 failed. Publication requires review.

Execution: preserved job completion and post-step logs verified. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Median build_and_reuse_seconds | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| cold | actions-cache | 1 | 656.8639490000003 | 656.8639490000003–656.8639490000003 | unmeasured | 0 |
| commit | actions-cache | 1 | 100.81440899999996 | 100.81440899999996–100.81440899999996 | unmeasured | 0 |
| cold | boringcache | 1 | 658.400308 | 658.400308–658.400308 | 983997286 | 1 |
| commit | boringcache | 1 | 193.70680499999997 | 193.70680499999997–193.70680499999997 | 985937000 | 1 |

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
