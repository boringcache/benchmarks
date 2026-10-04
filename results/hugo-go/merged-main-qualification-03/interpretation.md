# Merged Hugo Go qualification

[Run 37219016891](https://github.com/boringcache/benchmarks/actions/runs/37219016891)
completed the declared cold and identical-source warm jobs at main commit
`fac4677ae1b217db78662291b34fa89d6253f92c`, using CLI v1.33.0. Output verification,
preserved job completion, and post-step checks pass. The updated evidence hook
retained the original final product envelopes after cleanup.

The [report](report.md) records Actions Cache/BoringCache build-and-reuse times
of 53/69 seconds cold and 10/16 seconds warm. BoringCache is slower in both
observations. These single measurements do not establish a repeatable difference.
The declared scope excludes post-job work; it is not complete CI latency.

Actions Cache cold storage is unmeasured. The provider measurements describe
selected caches at their probe times, not equivalent physical storage or a
deduplication comparison. The cold BoringCache probe precedes final cleanup;
the later warm probe must not be interpreted as bytes written by the warm job.
[Cache-side evidence](cache-telemetry.json) identifies the warm proxy as read-only
and reports zero remote errors. These counters do not replace native output or
post-step evidence.

The [published bundle](https://github.com/boringcache/benchmarks/releases/download/evidence-merged-harness-2026-10-04/benchmarks-37219016891.tar.gz)
was downloaded again and verified against its digest and 17-file scoped inventory.
This qualifies the selected execution and retention path. Publication, other
workloads, schedule cutover, and repository retirement remain separate reviews.
