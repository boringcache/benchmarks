# Hugo Docker shared lifecycle qualification

[Run 37205110890](https://github.com/boringcache/benchmarks/actions/runs/37205110890) completed all four declared phases at signed harness `d045da272fae61c96d06727459055f1a31eca48f`. Both cold arms publish; both warm arms restore without publishing. The Actions Cache warm command has no cache export, and BoringCache uses restore trust with `--read-only`. Both image outputs are loaded within timing and inspected after timing.

The [report](report.md) retains Actions Cache/BoringCache build-and-reuse measurements of 229/226 seconds cold and 17/27 seconds warm. BoringCache is slower in this warm observation. These are single observations, not a repeatable performance claim. Actions Cache storage is unmeasured, so this series cannot establish a storage comparison.

Original final One evidence was retained after product cleanup. The [archive](https://github.com/boringcache/benchmarks/releases/tag/evidence-shared-lifecycle-2026-10-04) was downloaded again and verified against its SHA-256 and 15-file scoped inventory. [Repository cache capacity](../../../migration/cache-capacity-2026-10-04.json) is contextual and does not establish per-phase occupancy or absence of eviction. Other workloads and rolling publication remain unqualified.
