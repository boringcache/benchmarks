# deno: rolling-seed-cargo-product-01

Question: Does the pinned workload produce verified output and reuse its declared cache?

Measured scope: The two BoringCache Cargo release operations, including restore, build, and any permitted publication. Fresh changed-source consumers use restore-only trust; rolling jobs permit publication to the declared cohort. Output verification and unrelated setup are excluded. This is a correctness proof, not a provider timing comparison.

Status: all declared observations collected; 0 failed. Publication requires review.

Execution: preserved job completion and post-step logs verified. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| cold | boringcache | 1 | unmeasured | 0 |
| commit | boringcache | 1 | unmeasured | 0 |

Methodology prevents a comparative claim:

- This series does not declare a comparison of provider performance.

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
