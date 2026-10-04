# Merged Docker corpus qualification

[Run 37219031314](https://github.com/boringcache/benchmarks/actions/runs/37219031314)
completed the declared AMD64 cloudcost-exporter cold/warm proof at main commit
`fac4677ae1b217db78662291b34fa89d6253f92c`, using CLI v1.33.0. Recipe checks, both
builds, and preserved post-step completion checks pass. Original product evidence
is retained after cleanup. The common collector imports both canonical records
from the proof artifacts without reconstructing measurements from logs.

This recipe declares no loaded or pushed image. Its successful declared output
does not establish a runnable loaded image, application behavior, or a provider
comparison. The [report](report.md) treats the series as a correctness proof and
does not calculate a comparative timing claim.

Both probes report 580,038,317 selected Docker-tag bytes. This is not total
workspace or physical storage. [Cache-side evidence](cache-telemetry.json)
reports a read-only warm proxy, 16 warm object hits, zero warm misses, and zero
remote errors. Cold uses a fresh logical identity; shared underlying objects can
already exist. Object counts are not compiler hit rates.

The [published bundle](https://github.com/boringcache/benchmarks/releases/download/evidence-merged-harness-2026-10-04/benchmarks-37219031314.tar.gz)
was downloaded again and verified against its digest and 11-file scoped inventory.
This one-sample proof does not qualify other Docker cases, architectures, rolling
execution, publication, or repository retirement.
