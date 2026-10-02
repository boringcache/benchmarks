# Deno Cargo-product direct qualification

The direct workflow completed its predeclared cold seed and adjacent changed-source
build, output checks, and post steps on CLI 1.33.0. Preserved completion checks
pass. This qualifies this execution path for output correctness and observed
cache reuse. It does not establish a provider performance comparison or qualify
the separate rolling workflow.

The parent is `b8681dfa6442a0dfa5c7ddc43b279c504079cf2a`; the destination is
`b4f08f127652d8442b4d3dbabc277aca3840bc1d`. The workflow checks adjacency and clean
starting destinations. It builds and verifies the declared release binaries and
`denort_desktop`. The changed-source Action evidence reports a restored Cargo
target. The desktop operation can reuse state created by the primary operation
inside each job; cold refers to the initial logical cohort, not every command.

The recorded operation times are 3,333 seconds cold and 1,926 seconds changed
source. They span both Cargo product operations and intervening command selection.
The seed permits publication; the changed-source job is restore-only. Setup,
output verification, job duration, and queue time are excluded. Separate restore,
compile, and publication times remain unmeasured.

**The recorded 1,998,299,735-byte probe is not a qualified total for all selected
Cargo caches.** It equals the compiler-cache KV count observed after the run,
while that later inventory also contains registry and target archives. The
original probe output was not retained, so its per-tag byte coverage cannot be
established. The records and generated report retain the original observation;
it must not support a storage claim. The reporter now requires a byte measurement
for every selected tag and records a partial probe as an unmeasured total. The
later [inventory](cache-telemetry.json) is separately dated evidence, not a
replacement measurement at the original phase boundary.

Native sccache evidence also retains nonzero error counters: the primary cold
operation reports 10 cache errors, and the primary changed-source operation
reports 5. Changed-source operations report 52 and 3 cache write errors. These
are distinct from the cache-side run summary's zero remote transport errors.
Their causes are not established by this review. Successful outputs do not
establish an error-free compiler-cache run. The cache-side totals combine both
jobs and are not compiler hit rates or additive wall-clock durations.

Both jobs declare the same runner class, image version, OS, and architecture;
physical CPU and runner region are unmeasured. This one-sample correctness proof
does not satisfy a ten-sample publication comparison. No website performance
claim is promoted. See the [generated report](report.md) and
[preserved evidence](evidence.md).
