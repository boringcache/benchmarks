# Merged Deno Cargo qualification

[Run 37219039939](https://github.com/boringcache/benchmarks/actions/runs/37219039939)
completed the declared cold seed and adjacent changed-source build at main commit
`fac4677ae1b217db78662291b34fa89d6253f92c`, using CLI v1.33.0. Both jobs passed
the required executable-file, shared-library, and clean-source checks. Preserved
completion and post-step checks pass. The four original final product envelopes
were retained after cleanup, and the common collector imported both canonical
phase records from their mixed Cargo evidence bundles.

The parent is `b8681dfa6442a0dfa5c7ddc43b279c504079cf2a`; the destination is
`b4f08f127652d8442b4d3dbabc277aca3840bc1d`. Both changed-source operations report
a restored Cargo target. The consumer is restore-only and does not advance the
seed. The desktop operation can reuse state from the preceding operation within
each job; cold describes the initial logical cohort, not every command.

The recorded operation times are 2,725 seconds cold and 1,493 seconds changed
source. They include the two Cargo operations and intervening command selection,
with output verification and unrelated setup excluded. This single-provider,
one-sample proof does not establish a provider performance comparison, application
runtime behavior, or the separate rolling workflow's seed lineage.

The original native sccache evidence retains these counters:

| Operation | Cache errors | Cache write errors |
| --- | ---: | ---: |
| Cold primary | 10 | 0 |
| Cold desktop | 0 | 0 |
| Changed-source primary | 5 | 52 |
| Changed-source desktop | 0 | 3 |

Their causes are not established by this qualification. Successful outputs and
the [cache-side summary](cache-telemetry.json)'s zero remote errors do not establish
an error-free compiler-cache run. The cache-side changed-source job reports zero
remote bytes written; native write-error counters remain separate evidence.

Both storage probes retain a measured subtotal of 4,566,279,406 bytes across the
registry cache, registry index, Cargo target, and compiler cache. The selected
Git-dependency cache tag has no byte measurement. Consequently, the
[report](report.md) leaves total selected-cache storage unmeasured. Neither the
subtotal nor the absent tag establishes total physical or billable storage.

The [published bundle](https://github.com/boringcache/benchmarks/releases/download/evidence-merged-harness-2026-10-04/benchmarks-37219039939.tar.gz)
was downloaded again and verified against its digest and 13-file scoped inventory.
This qualifies the declared execution, collection, and evidence-retention paths.
Publication, remaining variants, schedule cutover, and repository retirement
remain separate reviews.
