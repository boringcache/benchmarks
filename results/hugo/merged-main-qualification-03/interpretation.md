# Merged Hugo Docker qualification

[Run 37219024516](https://github.com/boringcache/benchmarks/actions/runs/37219024516)
completed both providers' cold and identical-source warm jobs at main commit
`fac4677ae1b217db78662291b34fa89d6253f92c`, using CLI v1.33.0. Both arms load their
image inside the timer and inspect it afterward. Cold publishes; warm restores
without publishing. Preserved completion checks pass, including final original
product evidence retention after cleanup.

The [report](report.md) records Actions Cache/BoringCache build-and-reuse times
of 211/222 seconds cold and 22/25 seconds warm. BoringCache is slower in both
observations. One observation per arm and phase does not establish a repeatable
performance difference. Output inspection verifies the built image, not application
behavior.

Actions Cache storage is unmeasured. BoringCache reports 411,516,403 selected-tag
bytes in each phase; this is not total workspace or billable storage.
[Cache-side evidence](cache-telemetry.json) reports a read-only warm proxy, 14
warm object hits, zero warm misses, and zero remote errors. Logical cold identity
does not establish an empty physical cache store. Object counters are not compiler
hit rates or additive timing measurements.

The [published bundle](https://github.com/boringcache/benchmarks/releases/download/evidence-merged-harness-2026-10-04/benchmarks-37219024516.tar.gz)
was downloaded again and verified against its digest and 15-file scoped inventory.
The selected execution and evidence paths pass. This does not qualify the remaining
cases, rolling source lineage, publication, or schedule cutover.
