# Zed combined-cache qualification

[Run 37067843340](https://github.com/boringcache/benchmarks/actions/runs/37067843340)
completed the selected combined variant from signed harness
`086c025de4c974032f8aab6e3f5d6a8144f19845`, using CLI 1.33.0.
The cold parent seed and adjacent-source restore-only build passed their reviewed
recipe, output, job completion, and post-step checks. The shared restore matrix
ran only the declared combined variant.

This is one BoringCache correctness sample. No provider timing or storage
comparison is declared. Target-only, sccache-only, the newer rolling recipe, and
release/schedule callers require separate qualification. The
[recipe review](../../../cases/zed/recipe-review.md) describes the pinned release
projection and its limits.

The [generated report](report.json) retains both declared observations and
completion. The [durable evidence](evidence.md) was independently downloaded and
verified. Publication remains unreviewed; this proof does not establish a
performance advantage or qualify every Zed execution path.
