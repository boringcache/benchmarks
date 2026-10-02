# deno: rolling-cargo-product-qualification

Question: Does the pinned workload produce verified output and reuse its declared cache?

Measured scope: The two BoringCache Cargo release operations, including restore, build, and any permitted publication. Fresh changed-source consumers use restore-only trust; rolling jobs permit publication to the declared cohort. Output verification and unrelated setup are excluded. This is a correctness proof, not a provider timing comparison.

Status: 1 declared observations missing; 0 failed. Publication requires review.

Execution: unqualified; missing or failed job completion checks. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |

Methodology prevents a comparative claim:

- Rolling observations have no verified seed and changed-source sequence; retain them as diagnostic.
- This series does not declare a comparison of provider performance.

Run 37063477982 failed completion checks:

- Workflow concluded failure
- BoringCache Deno Cargo commit: failure

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
