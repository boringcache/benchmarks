# obs-studio: direct-ccache-runtime-qualification

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Status: all declared observations collected; 0 failed. Publication requires review.

Execution: preserved job completion and post-step logs verified. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Median build_and_reuse_seconds | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| cold | actions-cache | 1 | 486.020332187 | 486.020332187–486.020332187 | unmeasured | 0 |
| commit | actions-cache | 1 | 37.84547679900001 | 37.84547679900001–37.84547679900001 | unmeasured | 0 |
| cold | boringcache | 1 | 489.142139402 | 489.142139402–489.142139402 | 172198996 | 1 |
| commit | boringcache | 1 | 39.12283147599999 | 39.12283147599999–39.12283147599999 | 172198996 | 1 |

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
