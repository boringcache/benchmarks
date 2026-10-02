# hugo-go: direct-dispatch-qualification

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Status: all declared observations collected; 0 failed. Publication requires review.

Execution: preserved job completion and post-step logs verified. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Median build_and_reuse_seconds | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| cold | actions-cache | 2 | 79.5 | 78–81 | unmeasured | 0 |
| warm | actions-cache | 2 | 17.0 | 11–23 | 161851116.5 | 2 |
| cold | boringcache | 2 | 76.0 | 72–80 | 646497724.5 | 2 |
| warm | boringcache | 2 | 18.0 | 16–20 | 811503108.0 | 2 |

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
