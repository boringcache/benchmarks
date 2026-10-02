# Deno compiler-only direct qualification

The direct workflow completed its predeclared cold seed and adjacent changed-source
build, output checks, and post steps on CLI 1.33.0. Preserved completion checks
pass. This qualifies this execution path for output correctness and observed
compiler-cache reuse. It does not establish a provider performance comparison or
qualify the separate rolling workflow.

The parent is `b8681dfa6442a0dfa5c7ddc43b279c504079cf2a`; the destination is
`b4f08f127652d8442b4d3dbabc277aca3840bc1d`. The workflow checks adjacency and clean
starting destinations, and verifies the release binaries and `denort_desktop`.
The Action evidence selects only the compiler-cache tag: archive entries are
empty and `target_cache_hit` is false. Changed-source primary and desktop
operations report 2,484 and 533 compiler-cache hits respectively.

The recorded operation times are 3,397 seconds cold and 2,512 seconds changed
source. They span both Cargo product operations and intervening command selection.
The seed permits publication; the changed-source job is restore-only. Setup,
output verification, complete job duration, and queue time are excluded. Separate
restore, compile, and publication times remain unmeasured. Differences from the
Cargo-product qualification are single observations with different cache layers;
they do not qualify a comparison between those profiles.

Both phase probes report 1,998,299,927 bytes for the single exact compiler-cache
tag. The separately dated [cache inventory](cache-telemetry.json) agrees with
that KV count and shows no selected archives. This is selected provider-reported
storage, not physical or billable storage. There is no comparator measurement.

The primary cold and changed-source operations each report 10 native sccache
cache errors. Changed-source primary and desktop operations report 52 and 3
cache write errors. The causes are not established by this review. These counters
are distinct from the cache-side run summary's zero remote transport errors;
successful outputs do not establish an error-free compiler-cache run. Cache-side
run totals combine both jobs and are not compiler hit rates or additive
wall-clock durations.

Both jobs declare the same runner class, image version, OS, and architecture;
physical CPU and runner region are unmeasured. This one-sample correctness proof
does not satisfy a ten-sample publication comparison. No website performance
claim is promoted. See the [generated report](report.md) and
[preserved evidence](evidence.md).
