# Hugo Go wrapper qualification

The two predeclared samples completed all eight observations and passed output,
source, runner-environment, product-version, and preserved post-step checks.
This qualifies the shared fresh workflow for this Go workload. It does not qualify
the rolling workflow or all native cases.

BoringCache's median build and cache reuse time was 92.5 seconds cold and 20 seconds
warm. Actions Cache measured 85 seconds cold and 11.5 seconds warm. BoringCache was
slower in this screening series. The [generated report](report.md) retains all
observations, ranges, and provider-reported storage counts.

The measured operation includes cache restore/setup and Hugo's upstream Go build
entrypoint. Dependencies installed by that entrypoint remain included. Post-job
publication time is unmeasured and outside this metric. These numbers do not
compare complete job or workflow duration.

Both warm arms found their exact series seed. [cache-context.json](cache-context.json)
records the post-run GitHub cache inventory and repository occupancy. The snapshot
does not establish historical eviction, repository quota, runner-region equality,
or identical physical CPUs. The matched records establish the declared runner
class, image, image version, OS, and architecture.

Selected-cache storage is reported with its provider source. The BoringCache KV
counts and GitHub archive counts do not establish equivalent compression,
cross-tag deduplication, physical storage, or billable workspace usage. Cold
Actions Cache storage remains unmeasured because its save runs after recording.

Two samples establish a screening result, not the case's ten-sample publication
target. No website claim is changed. [evidence.md](evidence.md) links the independently
downloaded and verified archives. The earlier `shared-hugo-go` series remains
unqualified because its post-step logs reported publication failures.
