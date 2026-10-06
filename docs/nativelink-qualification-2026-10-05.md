# NativeLink R2 qualification

Status: NativeLink passed one cold/warm sample and its changed-source replay.
The second fresh sample is running. NativeLink is a cache-only gRPC
provider; see [its configuration and measurement boundary](../cases/grpc/nativelink.md).
This screening checks cache persistence, source continuity, and executable
outputs. It does not establish a performance ranking.

| Observation | Run | Status |
| --- | --- | --- |
| Initial fresh sample 1 | [37357216555](https://github.com/boringcache/benchmarks/actions/runs/37357216555) | Cold passed; three warm jobs never acquired runners; failed run archived; timing comparison excluded |
| Initial fresh sample 2 | [37357215892](https://github.com/boringcache/benchmarks/actions/runs/37357215892) | NativeLink warm job never acquired a runner; preserved failed run |
| Corrected fresh sample 1 | [37358851818](https://github.com/boringcache/benchmarks/actions/runs/37358851818) | Cold passed; NativeLink warm never acquired a runner; failed run archived |
| Corrected fresh sample 2 | [37358852206](https://github.com/boringcache/benchmarks/actions/runs/37358852206) | NativeLink cold and warm passed; other warm providers lost runners; whole run failed and is archived |
| Replacement fresh sample | [37374167360](https://github.com/boringcache/benchmarks/actions/runs/37374167360) | Running the final implementation; warm result pending |
| Initial rolling seed | [37357537232](https://github.com/boringcache/benchmarks/actions/runs/37357537232) | Cancelled; preserved |
| Replacement rolling seed | [37357892389](https://github.com/boringcache/benchmarks/actions/runs/37357892389) | Passed and archived |
| Rolling source advancement | [37365008673](https://github.com/boringcache/benchmarks/actions/runs/37365008673) | NativeLink attempt 2 passed with 3,787 remote hits and verified parent/child lineage; whole run failed; all attempts archived |

The initial fresh series excluded NativeLink installation from setup timing while
including BoringCache installation. Its methodology review excludes a timing
comparison. The corrected fresh series includes installation for both providers.
The initial rolling seed was cancelled after identifying that its 45-minute
budget was shorter than a prior successful GitHub Actions cold build. Its
replacement has a 90-minute budget and a new R2 scope.

The rolling seed uses `08455f8f03d2b1508ae233d950704ec06cb19017`; the advancement
uses its child `e1245717f658d10fee8fa0ea7b6f301a872330f2`, which changes the
compiled gRPC core version. Both use the isolated scope
`nativelink-r2-20261005-v2`. The CSM recipe contract is unchanged. The source pin
and explicit scope override live only on the rehearsal branch.

Fresh execution uses the frozen `ed4626fc` definition. The final implementation
also bounds startup queries and stores the raw R2 object inventory in a separate
artifact, with its checksum and totals in the phase record. The declared rolling
advancement exercises these changes. NativeLink version, server configuration,
Bazel commands, cache publication policy, and output checks are unchanged.
Unexecuted advancement plans 02 and 03 were superseded before dispatch; they
remain in rehearsal-branch history.

The rolling seed and advancement have different setup/reporting definitions;
they qualify continuity and outputs, not a timing comparison against one another.
Original plans, dispatches, observations, and failed attempts remain retained.
Verified run exports are published in the
[qualification evidence release](https://github.com/boringcache/benchmarks/releases/tag/evidence-nativelink-2026-10-05).

Shared cadence activation remains pending the compatible stable CLI release.
No historical schedules have been removed or duplicated by this change.

As of 19:50 UTC, GitHub reports an [Actions incident](https://www.githubstatus.com/incidents/3q1yb5m7ltvb)
beginning at 19:11 UTC. The initial sample 2 NativeLink warm job had no runner
and no steps; its failure annotation states: "The job was not acquired by Runner
of type hosted even after multiple attempts". This is an infrastructure failure,
not a completed warm observation. Preserve these failures without inventing timings.

The final implementation passes 259 tests / 2,043 assertions and hosted guardrails.
PR #43 is merged; Zed Nix passed both fresh samples and its rolling seed/advance.
PR #44 remains open pending the second successful NativeLink cold/warm sample.

The rolling replay verified 3,787 remote hits from an empty local cache, retained
the seed run and source revision, and verified the changed-source client and
server executables. The R2 inventory contains 19,893 objects totalling
756,897,941 bytes; the raw inventory checksum matches its phase receipt.
Attempt 2 has a separate verified evidence archive, preserving the earlier
attempt export. The series remains failed because the complete provider cohort
did not finish successfully; NativeLink correctness does not approve a provider
timing comparison.
