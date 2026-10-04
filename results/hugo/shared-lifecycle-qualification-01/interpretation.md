# Shared lifecycle request failure

[Run 37204584632](https://github.com/boringcache/benchmarks/actions/runs/37204584632) failed before building. The shared phase helper emitted hyphenated output names that the existing output writer rejected. No phase measurements were produced, and the original failed completion remains in the [report](report.md).

The correction uses supported output names and tests the actual helper CLI. A [separate replacement series](../shared-lifecycle-qualification-02/interpretation.md) declares the changed execution definition; this request is not rewritten or counted as successful qualification.

The [archive](https://github.com/boringcache/benchmarks/releases/tag/evidence-shared-lifecycle-2026-10-04) was downloaded again and verified against its SHA-256 and seven-file scoped inventory.
