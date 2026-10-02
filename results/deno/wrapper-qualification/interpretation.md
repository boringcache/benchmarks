# Deno Cargo wrapper qualification

The predeclared cold seed and adjacent changed-source observation completed
release-output checks and preserved job and cleanup checks. This qualifies the
shared wrapper for this Deno `cargo-product` proof on CLI 1.33.0. It does not
qualify the compiler-only profile, rolling chain, or a provider timing comparison.

The seed is `b8681dfa6442a0dfa5c7ddc43b279c504079cf2a`; the destination is
`b4f08f127652d8442b4d3dbabc277aca3840bc1d`. The workflow checks their one-commit
parent relationship and empty starting destinations, builds the declared Deno
release binaries and `denort_desktop`, and verifies their outputs. The changed
job restored the seed on a fresh runner. Both jobs used the same declared runner
class, image version, OS, and architecture; this does not establish identical
physical CPUs or runner regions.

The operation observations were 3,591 seconds cold and 2,059 seconds changed
source. Each spans the two Cargo product operations and intervening command
selection. The cold operations include publication; the changed-source consumer
uses restore-only trust and performs no publication. These observations are
single-provider context, not a cache speedup estimate. Unrelated setup, output
verification, complete job duration, and queue time are outside this measurement.
Separate restore, compile, and publication durations remain unmeasured.

Both storage probes reported 1,998,300,451 bytes for the selected resolved seed
tags through `boringcache-check`. The consumer did not update them. This is a
provider-reported selected-cache count, not workspace-wide, physical, or billable
storage, and there is no equivalent comparator storage measurement.

[Cache telemetry](cache-telemetry.json) records 1,837 remote hits and 59 missed
lookups in the changed-source job, with no reported cache transport errors. These
lookups span archive and sccache activity and do not establish a compiler hit rate
or additive phase durations. The original phase records list the case's declared
verification checklist; preserved job logs identify the checks actually executed
in each phase. The later reporter separates declared requirements from completed
phase verification.

The [generated report](report.md) retains both observations. The [evidence archive](evidence.md)
was independently downloaded and verified. This one-sample correctness proof
does not satisfy a ten-sample publication comparison. No website performance
claim is changed by this qualification. The earlier cancelled Cargo proof remains
preserved and unqualified.
