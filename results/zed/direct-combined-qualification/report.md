# zed: direct-combined-qualification

Question: Does the pinned workload produce verified output and reuse its declared cache?

Measured scope: The BoringCache Cargo operations, including their restore, build, and publication; output verification and unrelated setup are excluded. The layer proof uses a combined cold seed for each restore-only variant and makes no provider timing comparison.

Status: all declared observations collected; 0 failed. Publication requires review.

Execution: preserved job completion and post-step logs verified. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| cold | boringcache | 1 | 8994101532 | 1 |
| commit | boringcache | 1 | 8994101532 | 1 |

Methodology prevents a comparative claim:

- This series does not declare a comparison of provider performance.

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
