# deno: consolidated-cargo-proof

Question: Does the pinned workload produce verified output and reuse its declared cache?

Measured scope: The two BoringCache Cargo release operations, including their restore, build, and publication; output verification and unrelated setup are excluded. This is a correctness proof, not a provider timing comparison.

Observations: 0/2 recorded; 0 failed; 2 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |

Comparison checks:

- This series does not declare a comparison of provider performance.

Run 37018642899 failed completion checks:

- Workflow concluded cancelled
- qualification-deno / BoringCache Deno Cargo cold: cancelled
- qualification-deno / BoringCache Deno Cargo changed source: cancelled

Missing observations:

- Sample 1, BoringCache, Cold build
- Sample 1, BoringCache, Changed-source build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |

[Full records and checks](report.json)
