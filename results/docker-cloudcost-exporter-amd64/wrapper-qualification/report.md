# docker-cloudcost-exporter-amd64: wrapper-qualification

Question: Does the pinned workload produce verified output and reuse its declared cache?

Measured scope: Declared Docker build, including dependencies, cache import/export and declared image output

Status: all declared observations collected; 0 failed. Publication requires review.

Execution: preserved job completion and post-step logs verified. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Median correctness | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| cold | boringcache | 1 |  |  | unmeasured | 0 |
| warm | boringcache | 1 |  |  | unmeasured | 0 |

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
