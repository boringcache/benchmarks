# n8n: shared-turbo-qualification-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Status: all declared observations collected; 0 failed. Publication requires review.

Execution: preserved job completion and post-step logs verified. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Median build_and_reuse_seconds | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| cold | actions-cache | 1 | 125 | 125–125 | unmeasured | 0 |
| warm | actions-cache | 1 | 4 | 4–4 | 52937490 | 1 |
| cold | boringcache | 1 | 132 | 132–132 | 46409937 | 1 |
| warm | boringcache | 1 | 9 | 9–9 | 51597365 | 1 |

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
