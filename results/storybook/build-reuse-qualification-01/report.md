# storybook: build-reuse-qualification-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed Storybook sandbox build plus measured cache restore/setup; dependency installation and sandbox creation are excluded; output checks and unmeasured post-job save are reported separately

Status: all declared observations collected; 0 failed. Publication requires review.

Execution: preserved job completion and post-step logs verified. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Median build_and_reuse_seconds | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| cold | actions-cache | 1 | 15 | 15–15 | unmeasured | 0 |
| warm | actions-cache | 1 | 17 | 17–17 | 1226001 | 1 |
| cold | boringcache | 1 | 18 | 18–18 | unmeasured | 0 |
| warm | boringcache | 1 | 19 | 19–19 | 1212413 | 1 |

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
