# Hugo Go shared lifecycle qualification

[Run 37204582423](https://github.com/boringcache/benchmarks/actions/runs/37204582423) completed the declared one-sample cold/warm comparison. Original final One evidence was uploaded after product cleanup. The preserved jobs and post-step logs pass completion checks.

The [report](report.md) retains Actions Cache/BoringCache build-and-reuse measurements of 84/63 seconds cold and 8/15 seconds warm. BoringCache is slower in this warm observation. One observation per arm and phase does not establish a repeatable performance difference. Actions Cache cold storage is unmeasured; the available provider storage values are not complete equivalent storage accounting.

The [archive](https://github.com/boringcache/benchmarks/releases/tag/evidence-shared-lifecycle-2026-10-04) was downloaded again and verified against its SHA-256 and 17-file scoped inventory. This qualifies the selected execution and retention path, not publication or the remaining cases. [Repository cache capacity](../../../migration/cache-capacity-2026-10-04.json) is contextual and does not prove absence of eviction.
