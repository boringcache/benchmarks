# Consolidation acceptance

## Current cutover gates

The central definitions and shared harness exist. Active schedules, the historical
index feed, and original repositories still require a verified cutover. Use the
same [case process](process.md) for a maintained benchmark or a selected evaluation;
adding an evaluation does not require a fork or another harness.

| Area | Current state | Remaining acceptance |
| --- | --- | --- |
| Definitions and execution | 17 maintained cases, 47 Docker workloads, and four blocked gRPC evaluation drafts; one provider wrapper and workspace | Qualify each scheduled workload and variant, including output checks and cache source lineage |
| Docker lifecycle | One shared provider/timing action; equal publication policy; corrected Hugo and both PostHog profiles pass cold/warm execution with final product evidence retained after cleanup | Qualify the remaining workload and rolling paths |
| Reporting and evidence | One canonical phase/series format, verified collection, generated catalog, preserved failures and methodology reviews | Reviewed central publication feed and complete required evidence for each retiring repository |
| Product updates | One Action pin; pin-sync and product-interface checks inspect shared execution views | Complete companion integration and released-product qualification before caller activation |
| Scheduling | Monitoring reads the existing active schedules | Qualify central source-sync/canary/release callers, then retire each replaced schedule |
| Shared GitHub capacity | Serial comparisons; capacity snapshots retained | Choose retention/capacity policy and verify seed availability for rolling comparisons |
| Fork retirement | Deferred inventory and selected candidates retained | Audit unique work, evidence, external links, and active upstream contributions before each decision |

The [October 4 capacity snapshot](../migration/cache-capacity-2026-10-04.json)
records 10,650,140,305 bytes in 274 cache entries and the API's `max_cache_size_gb`
setting of 10. This is repository context, not a per-phase measurement or proof
of eviction. A later contextual snapshot records 11,885,301,507 bytes in 289
entries. Neither snapshot establishes that a particular seed survived. Capacity
and seed checks remain required before activating central schedules.


The first cutover migrates the 18 maintained `benchmark-*` repositories:
17 benchmark cases and Docker's 47 pinned workloads. Fork evaluations are deferred
in `migration/forks.json`. Original forks and benchmark repositories remain
unchanged until verification.

[Active screening requests](../migration/active-screening-2026-10-03.json) record
eight one-sample native comparisons and two fresh Deno seed proofs dispatched
from signed harness `da6400b3`. Each series was committed before dispatch. These
requests do not establish completion or approve publication. Repository-wide
cache API snapshots record 2,181,622,414 bytes in 146 entries and a 10 GB limit.
They are context, not per-phase occupancy or proof that no eviction occurred.
Native comparisons share a serial queue; Deno's two fresh seeds use separate
BoringCache identities for the later rolling qualification.

The branch imports pinned recipes and historical reports, uses one workspace,
replaces maintained Python tooling with Ruby, and shares the publication registry.
Historical reports retain their original interpretation and execution URLs.
Importing a report does not establish raw-evidence completeness or current-product
applicability.

Verify these conditions for each repository:

1. Inventory branches, exact revisions, unique recipes, and patches.
2. Reproduce preparation, verify outputs, and complete a consolidated run using
   GitHub OIDC in `boringcache/benchmarks`.
3. Export attempts, jobs, logs, artifacts, commits, and workflows needed by claims;
   verify checksums and durable evidence links.
4. Switch source-sync, schedules, canary/release dispatches, product checks, website
   claims, and other callers that depend on the original repository.
5. Record a retirement decision. Active upstream PRs and repository-boundary
   experiments may require retaining a fork or fixture.

No repository is deletion-ready merely because its definition was imported.
The existing `boringcache/benchmarks` workspace is connected through GitHub OIDC.
The [connection run](https://github.com/boringcache/benchmarks/actions/runs/37016106096)
verified CLI 1.33.0 through the official signed installer and completed enrollment
with restore and trusted-job publication access. Individual workload execution
and reporting qualification remain required.
Imported execution workflows accept explicit dispatch only until their live
qualification passes. Schedules and source-triggered execution must be enabled
as part of the reviewed caller cutover. PR validation runs the harness guards.

The shared native fresh path also selects individual n8n Turbo/Docker, Mastodon
server/streaming, and PostHog cache profiles from reviewed variant metadata;
Immich's server uses the same path without a variant. Their imported matrices
remain registered diagnostics. Loaded-image checks and live execution are
qualified per selected variant; they do not establish application runtime
behavior or qualify the original rolling publication behavior. Existing callers
and schedules still use the original repositories.
Four initial screens (Chroma, Duckgres, Hugo Docker, and Linkerd2) were cancelled
after review found missing image output checks. Their original plans, receipts,
cancelled completions, and scoped evidence remain preserved. Their replacement
fresh recipes load an image in both arms and use the shared output checker;
timing includes export and load. Chroma, Duckgres, and Linkerd2 completed their
replacement screens. Hugo's first replacement failed in both providers because
the Docker exporter rejected its attestation manifest list; a separate corrected
plan disables those attestations for loaded output in both arms. Original rolling
publication projections remain diagnostic.
The same checker and load projection apply to the selected n8n Docker, Mastodon,
PostHog, and Immich server recipes. Native preparation enforces the output
requirement before creating a source checkout. No image load or application
behavior is claimed for their older cache-only results.
The native Docker actions also use the shared Ruby source preparer. Chroma's
[recipe review](../cases/chroma/recipe-review.md) records the removal of its old
diagnostic source-layer marker from the identical-source replay. The replacement
timings must not be combined with that earlier projection.

The October 4 review found a shared fairness error in those Docker comparisons:
Actions Cache exported warm state while BoringCache restored without publishing.
Plan-bound reviews now mark all affected recorded Docker series ineligible for a
comparative claim, retaining the original measurements and successful output
checks. The shared `docker-benchmark` action now owns setup, timing, and the same
publication decision for both providers. Cold publishes; ordinary warm replay
does not. Explicit warm publication applies to both arms.

The [lifecycle screening archive](https://github.com/boringcache/benchmarks/releases/tag/evidence-lifecycle-review-2026-10-04)
preserves the six completed PostHog layers/combined, Hugo, Mastodon streaming, and
n8n runners/distroless runs requested on October 3. Their four phase records per
run are imported through `bin/bench collect`; each published bundle was downloaded
again and verified against its checksum and 13-file inventory. These runs retain
the same publication-policy limitation. They also lack the original final One
evidence envelope. The new provider post hook retains that envelope after product
cleanup. Corrected execution requires new frozen series and live qualification.

The corrected [Hugo Go](../results/hugo-go/shared-lifecycle-qualification-01/interpretation.md)
and [Hugo Docker](../results/hugo/shared-lifecycle-qualification-02/interpretation.md)
screens pass cold/warm output, post-step completion, and final product evidence
retention. Their one-sample records preserve BoringCache's slower warm results
and missing Actions Cache storage. The three initial Docker requests failed
before building on unsupported helper output names. All five completed requests
are retained in the [verified shared-lifecycle archive](https://github.com/boringcache/benchmarks/releases/tag/evidence-shared-lifecycle-2026-10-04),
with 53 listed files verified after download. Corrected PostHog
[layers](../results/posthog/shared-layers-lifecycle-02/interpretation.md) and
[combined](../results/posthog/shared-combined-lifecycle-02/interpretation.md)
screens also pass both providers' cold/warm output and completion checks. Their
original final product evidence is retained after cleanup. Actions Cache storage
is unmeasured. The combined record's selected Docker-tag bytes do not establish
coverage of tool-cache storage, and identical-source replay does not isolate
tool-cache benefit. Durable publication verification for these two exports is
recorded separately in the evidence inventory.

Canary monitoring now follows the active historical schedules through explicit
registry metadata. Its October 4 read-only collection verified all 16 repository
receipts and 17 child runs successfully. Central dispatch remains manual until
each schedule is qualified and cut over. This fixes monitoring without treating
an imported definition as an active central schedule.
n8n Turbo's primary measurement now captures cache setup and the build separately
from its dependency installation. The install still runs before the build. Earlier
results retain their original timed scope and must not be mixed with this series.
Storybook's first fresh screen also timed dependency installation and sandbox
creation in its setup metric. Its plan-bound methodology review prevents a
comparative claim while retaining every original observation. The replacement
recipe stops the setup timer before those operations. Its new one-sample series
completed output and preserved completion checks, retaining the slower
BoringCache measurements.

The [image-output archive](https://github.com/boringcache/benchmarks/releases/tag/evidence-image-output-2026-10-03)
preserves all eight frozen requests at `35e10981`, including the failed Hugo and
PostHog executions. Six selected paths completed cold/replay output and completion
checks: Chroma, Duckgres, Linkerd2, n8n Docker, Mastodon server, and Immich server.
The PostHog cold records also include inspection inside the timer, contrary to
their declared scope. A plan-bound methodology review prevents comparative use.
The [PostHog review](../cases/posthog/recipe-review.md) records the scope and timer
fixes; the [Hugo review](../cases/hugo/recipe-review.md) records its loaded-output
projection. New plans at signed `docker-output-correction-2026-10-03` request
PostHog layers, PostHog combined, and Hugo qualification without changing the
earlier declarations.

The [build/reuse archive](https://github.com/boringcache/benchmarks/releases/tag/evidence-build-reuse-2026-10-03)
preserves the corrected Storybook screen and both Deno seed-advance runs at
`b3ab6324`. Deno's publication-capable operations completed against the declared
parent cohorts, but remain diagnostic correctness investigations pending a generic
verified lineage contract. Native errors and unmeasured selected-tag storage
remain visible. Both archive releases were independently downloaded, checked
against archive digests, extracted, and verified against their scoped inventories.
One-sample screens do not approve publication, caller cutover, or deletion.
GitHub's default CodeQL configuration now scans Ruby and Actions. Python was
removed from its language list because this branch removes the maintained Python
reporter; query suite, threat model, weekly schedule, and runner settings were
preserved. The new evidence post hook adds maintained JavaScript on this branch.
After it reaches the default branch, verify that default CodeQL setup includes
`javascript-typescript` and its analysis passes. [GitHub automatically detects
new supported languages](https://docs.github.com/en/code-security/concepts/code-scanning/setup-types)
and can revert a failing new configuration. Correct missing coverage while
preserving Ruby and Actions, the existing query suite and threat model, weekly
schedule, and runner settings.
The hook's Node regression already runs in PR guardrails.
Archiving does not preserve expiring Actions evidence. Missing evidence and
unverified execution remain explicit in the inventory.

llama.cpp run `36902057374` has a verified export of its listed attempt, logs,
artifacts, commit, and workflow. The [archived bundle](https://github.com/boringcache/benchmarks/releases/tag/evidence-llama-cpp-36902057374)
was downloaded after upload, checked against its SHA-256, extracted, and verified
against its run inventory. `migration/evidence.json` records that verification.
This scoped export is not a completeness audit of the fork.

The [historical website run archive](https://github.com/boringcache/benchmarks/releases/tag/evidence-website-runs-2026-10-02)
preserves 52 runs linked from the website's snapshot, reviewed evidence, demo,
pilot data, adapter guide, tool-page models, and blog views. Independent download,
digest, and inventory checks passed for 51 complete scoped exports. Hugo Go run
`27092625118` remains partial because its logs are unavailable. One legacy gRPC
URL returned 404; the same run ID is verified in its original `benchmark-grpc`
repository, and companion PR 1014 corrects that link. Measurements are unchanged.
[`migration/website-evidence.json`](../migration/website-evidence.json) records
the exact references, original repositories, preserved directories, and gaps.
This is an evidence inventory, not a branch/fork completeness audit.
The [historical website report](../results/historical-website/report.md) preserves
the ten reviewed summaries with exact measurements, product versions, original
execution links, and the export state for each cited run. It provides specific
destinations for the companion website change without presenting historical
observations as results from the new executor.

The shared wrapper now has verified live qualification for a two-sample
[Hugo Go fresh comparison](../results/hugo-go/wrapper-qualification/interpretation.md),
an AMD64 [Docker cold/warm product proof](../results/docker-cloudcost-exporter-amd64/wrapper-qualification/interpretation.md),
and a [Deno Cargo cold/changed-source proof](../results/deno/wrapper-qualification/interpretation.md).
Their evidence was published, downloaded again, and checked against the bundle
digests and exported inventories. Earlier runs that failed post-step checks remain
preserved and unqualified. Per-case qualification and caller cutover remain
pending. These representative runs do not qualify every imported workload.

The first live qualification uses the already registered `guardrails.yml` caller
on this branch to invoke the actual reusable workflows. `executions.json` records
that caller and the workflow it invoked. It does not claim that the new workflow
was dispatched directly or reconstruct a missing original dispatch response.
Once the workflows are registered on the default branch, use the documented
`bin/bench run` path and retain its dispatch receipt.

The shared harness is merged. The direct
[Hugo Go comparison](../results/hugo-go/direct-dispatch-qualification/interpretation.md)
and [Docker AMD64 proof](../results/docker-cloudcost-exporter-amd64/direct-dispatch-qualification/interpretation.md)
pass preserved completion checks with exact dispatch receipts. Their
[archive release](https://github.com/boringcache/benchmarks/releases/tag/evidence-direct-dispatch-2026-10-02)
was independently downloaded and verified. Deno's
[Cargo product](../results/deno/direct-cargo-product-qualification/interpretation.md)
and [compiler-only](../results/deno/direct-compiler-only-qualification/interpretation.md)
direct runs pass their predeclared one-sample output, cache-reuse, and completion
checks. Their archived bundles were independently downloaded and verified. Native
compiler-cache errors remain in the evidence. The Cargo product's original storage
probe does not establish coverage of every selected tag and cannot support a total
storage claim. These runs do not qualify provider performance, the rolling
publication workflows, or the full release caller. OBS ccache/Xcode and Deno
rolling plans were dispatched from signed harness `50f069f`. The first OBS ccache
pair failed before building because Ruby 3.4.4 has no Ubuntu 26.04 binary. Both
failed completions and their [verified evidence](../results/obs-studio/direct-ccache-qualification/evidence.md)
are retained. The harness now reads Ruby 3.4.10 from one project pin and checks
preparation on the declared Ubuntu 26.04 and macOS 26 runners. A replacement ccache
series has its own frozen plan. Hosted preparation now passes on both runners.
The [Xcode pair](../results/obs-studio/direct-xcode-qualification/interpretation.md)
passed preserved output and completion checks, and both evidence bundles were
independently downloaded and verified. This one-sample screen retains BoringCache's
slower changed-source observation. Actions Cache storage was unmeasured; its
reporting token is now scoped to future reporting steps. Existing records remain
unchanged. The [replacement ccache pair](../results/obs-studio/direct-ccache-runtime-qualification/interpretation.md)
passed output and completion checks. Its one-sample timings retain both arms and
the missing Actions Cache storage; both archives were independently downloaded
and verified.
Deno's Cargo-product rolling run passed builds and output checks, then failed
uploading the profile-specific report. Its [failed completion and scoped archive](../results/deno/rolling-cargo-product-qualification/evidence.md)
are retained; the original phase and product files were not uploaded. The
[compiler-only rolling run](../results/deno/rolling-compiler-only-qualification/interpretation.md)
failed the same upload path at the older harness; its failed completion and
incomplete report and independently verified scoped archive are retained. The uploader
now selects the profile-specific filename and retains raw evidence even after a
later reporting failure. Reviewed Xcode publication, rolling Deno, replacement ccache,
and the full release caller remain unqualified. Original schedules and
repositories remain active.

The legacy index collector continues to read the original execution repositories.
It cannot publish raw central Actions summaries or mix them into historical
windows. New central claims use reviewed canonical series reports. Migrating the
legacy index to those records remains a reporting cutover gate.

The gRPC case declares its BuildBuddy arm alongside BoringCache and Actions Cache,
so a series cannot omit the third provider's observations. Its credential is
passed only to BuildBuddy matrix jobs. The existing organization secret is
restricted to `benchmark-grpc`; central access must be configured before gRPC
qualification or caller cutover.

Zed's imported layer preparation initially selected the newer rolling recipe
contract and failed its toolchain digest check. The layer path now selects a
separate reviewed contract through the shared verifier. Both pinned layer sources
and the rolling source pass file and command verification in a disposable
checkout. The layer contract checks all eight active plans. This corrects
preparation. The [combined variant](../results/zed/direct-combined-qualification/interpretation.md)
passed its one-sample cold/adjacent-source output and completion checks with an
independently verified archive. Other variants, rolling recipe, and caller
qualification remain pending. The
[recipe review](../cases/zed/recipe-review.md) records the two toolchains and
the release-build projection's limitations.
