# Add and run a benchmark case

## 1. Inspect the workload

Read the upstream workflow and relevant build files. Identify its output, normal
source changes, existing cache, and the operation the proposed cache can improve.
Check existing cases first. Record recipe changes as patches or explicit
projections; distinguish them from faithful upstream execution.

## 2. Define the case

Create a blocked draft through the same interface:

```sh
bin/bench new <case-id> --repository <owner/repository> --revision <full-sha> --question 'What are we evaluating?'
```

Edit `cases/<case-id>/case.json` using `schemas/case.schema.json`. Start with
`kind: evaluation` and `reporting.publication: evaluation-only`. Use JSON, exact
source SHAs, and the workspace `boringcache/benchmarks`.

Declare the question, providers, primary metric, timed scope, storage measurement,
cache scope, sample count, workflows, and output verification. Workflow payloads
live in `cases/<case-id>/payload/`. Docker workloads use `recipe.json` and `plans/`
with the shared Docker adapter. Do not vendor upstream source: `bin/bench prepare`
obtains the declared revision and applies recorded patches in a disposable checkout.

Record reviewed upstream file digests and build commands in `recipe-contract.json`.
When a case has distinct pinned recipes, use a named contract with the same
`verify-upstream-recipe.rb <source-directory> <contract-file>` verifier. A contract
can declare groups of plan paths with a shared adapter and command under `plans`;
the verifier checks every named plan. A digest mismatch requires reviewing the
source, command, and environment changes before updating the contract. Zed's
[recipe review](../cases/zed/recipe-review.md) distinguishes its older Cargo layer
proof from its newer rolling recipe.

For the standard BoringCache/Actions Cache comparison, use
`native-fresh-benchmark.yml` and `native-rolling-benchmark.yml`. Declare the local
composite action, benchmark ID, toolchain inputs, and lane-specific publication
settings in `execution.native`. Register `case_id` in the workflow inputs. The
shared executor prepares that reviewed action on the disposable runner; agents
do not copy workflow setup or reporting into each new case. Declare tag mappings
in `execution.cache_tags` and use `scope-case-cache.rb`. Use `prepare-source.rb`
for an unchanged pinned upstream checkout.

When one case has several workloads, declare their recipe overrides in
`execution.native.variants` and register the same variants on the shared workflow
entry with `variant_input: variant`. Select one variant before execution:

```sh
bin/bench plan n8n --variant turbo
bin/bench prepare n8n --native-lane fresh --variant turbo --directory /tmp/n8n-turbo
bin/bench start n8n --series screening-turbo-01 --variant turbo --samples 1
```

The selected variant fixes the case action, benchmark ID, toolchain inputs, and
report identity. Provider-specific boolean flags belong in `provider_flags`;
for example, the Actions Cache arm keeps BoringCache's tool-proxy flags disabled.
All variants use the same provider lifecycle and canonical reporter. Missing or
unknown variants fail before dispatch. Contract checks prepare every registered
native variant, including its report filenames. A fresh variant passing does not
qualify another variant or the original rolling matrix.
Native planning also rejects a phase action that does not report verified output.
Add and review the actual output check before setting `--verified-output`; the
flag alone does not verify a workload. Schema and file-contract checks can pass
while an imported recipe still lacks that execution requirement.
For native Docker comparisons that declare `load_image`, fresh inputs must set
it to `true`. Both arms then export and load their built image during the timed
build. The shared `verify-docker-output.rb` checks the selected provider's image
after timing and passes verification to the reporter only after inspection
succeeds. The image check establishes that the build produced the declared image;
application behavior requires any additional checks declared by the case.
Publication and cache-only projections remain diagnostic until their output and
comparison boundary have been reviewed. Do not add the verification flag to a
cache-only build.

Keep different provider sets, architectures, source-change sequences, and output
behavior explicit in their adapters or case actions. OBS, Cargo product proofs,
and the Docker corpus retain their distinct execution shapes. Add a workflow
only when the experiment requires a different shape, and register it in the case.
Use the canonical Ruby reporter for every execution path. Add
suite membership for an explicit scheduling purpose. `suites/published.json` is
the shared registry for published reporting.

`.github/actions/boringcache` is the sole BoringCache One invocation and release
pin. It forwards the public product inputs and evidence outputs. Tool setup uses
shared actions such as `prepare-case`, `setup-docker`, and `setup-node`; case
actions retain their upstream commands, patches, and output verification. Native
fresh and rolling workflows support both dispatch and `workflow_call`. Use them
for evaluations and published cases without copying the provider lifecycle.
Reusable callers declare `contents: read`, `actions: read`, `packages: read`, and
`id-token: write` for the called job. GitHub checks these permissions when loading
the workflow, including calls whose execution condition is false.
Docker tool caches remain product-plan settings rather than a second implementation
of the product's proxy or cache lifecycle.
Docker case actions call `.github/actions/docker-benchmark` for provider setup,
timing, and execution. One phase policy controls cache publication in both arms:
cold publishes; an identical-source warm replay restores without publishing;
an explicitly declared `publish-on-warm` observation publishes in both arms.
Image loading stays inside this action's timer. Output inspection runs after it.
Use `benchmark-phase.rb scope` for the shared case/series identity, and keep
tool-specific tags in the product plan.

The provider wrapper registers `.github/actions/retain-product-evidence` before
calling One. Its GitHub post hook runs after One's cleanup, then uploads the
original final evidence JSON using GitHub's artifact SDK. Missing or invalid
evidence fails retention. The small JavaScript hook is required for GitHub post
steps; it does not interpret product measurements or implement cache behavior.
Its dependencies install during preparation, outside the comparison timer.
The Ruby reporter retains its structured measurements; the original envelope
remains a separate artifact so post-step status and future product fields survive.
The harness Ruby version is pinned once in `.tool-versions`. Ruby setup reads
that file from the harness checkout, including when a shared action is called
from an older benchmark repository. Guardrails verify preparation on Ubuntu
26.04 and macOS 26 as well as running the full harness checks on Ubuntu 24.04.
Runtime support must be verified before selecting a new runner or Ruby version.
BoringCache Action cache failures fail benchmark jobs. The wrapper sets that
policy literally and converts the optional cache-miss input to a boolean expression.
Retain native tool error counters separately. Successful outputs do not establish
an error-free native cache operation; review those counters before making a claim.
Nested composite post steps can receive a different input context; forwarding a
boolean as an unchecked string can become empty during cleanup. Qualification
must inspect post-job logs and evidence as well as the job conclusion.

## 3. Validate before execution

```sh
bin/bench check <case-id>
bin/bench plan <case-id> --lane fresh
bin/bench prepare <case-id> --directory /tmp/<case-id>-workload
```

For a standard native comparison, add `--native-lane fresh` to prepare and inspect
the resolved `.github/actions/benchmark-phase/action.yml`. Its cache publication
behavior and toolchain come from the case definition. Runtime canary inputs pass
through the shared workflow; they do not replace the case identity or recipe.

Check prepared source, recipe, commands, and output verification. Recipe digest
changes require review. Schema and workflow checks do not establish that a build
works or that its comparison is fair.

## 4. Declare a series

```sh
bin/bench start <case-id> --series screening-01 --lane fresh --samples 2
```

`results/<case-id>/<series-id>/series.json` freezes the question, providers, pins,
scope, phases, and sample count before execution. Use a new series for a changed
plan. Publication series normally use the case's declared ten measurements where
cost permits. Smaller screening series must be identified as screening.

Keep execution files at the reviewed harness ref when creating and dispatching
the series, and commit the plan before execution. The definition digest includes
shared execution and reporting code as well as the case. A later code change
invalidates the plan for that checkout. Return to the original harness ref to
continue its declared observations, or start a new series before execution.
Adding result records does not change the execution definition.

Fresh series declare either a cold build and identical-source replay, or a cold
parent seed and changed-source build. The workflow's `phases` declares the latter
as `["cold", "commit"]`; it must never be labelled an identical-source warm replay.
Rolling series contain changed-source commit observations and retain the parent cache seed.
Identities include case and series. Cases share a workspace but must not share
cold cache identity accidentally. A fresh tag or scope establishes a logical
cold seed; it does not establish an empty physical provider store. Keep existing
workspace/repository storage context and do not claim zero prior stored content
from namespace isolation alone.

GitHub cache quota remains repository-wide. Control concurrency and record
occupancy and eviction. Key prefixes do not create separate quotas. Keep fixture
repositories when repository boundaries are part of the question.
Provider-comparison workflows share a concurrency group so separate cases cannot
write competing GitHub cache seeds simultaneously. Qualification must still check
cache occupancy, quota, and the actual restored key; serialization does not give
each case its own quota.
The group uses `queue: max` so waiting observations are not replaced by newer
dispatches. [GitHub documents the 100-run queue limit](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency).
`scripts/lint-workflows.rb` checks that property and runs Actionlint 1.7.12 for
the remaining workflow syntax; that linter version does not recognize `queue`.

## 5. Execute and record

Use `bin/bench run <case-id> --series <series-id> --sample 1 --ref <reviewed-ref>` for a registered workflow.
Repeat with the next declared sample number. Use `--workflow <filename>` when a
case has more than one execution path. A receipt is retained for each sample and
workflow; a changed case requires a new series. Use `--variant` at series creation
when measuring a particular workload variant.
Workflows that declare `variants` require one of those variants at series creation.
When a variant selects a workflow input, declare `variant_input` in the workflow
entry. The plan fills that input from `--variant` and rejects a conflicting value.
The Zed layer proof uses the same combined cold seed for its target-only,
sccache-only, and combined restore probes; it establishes output correctness and
cache behavior rather than a comparison between providers. The frozen variant
selects `cache_layer`; one shared restore matrix runs only that selected probe.
Manual `cache_layer: all` runs the diagnostic matrix against a common cold seed.
Inspect the planned receipt before retrying an uncertain dispatch. Never
redispatch blindly after an interrupted request.

Time the operation declared by the case: build and cache reuse, with storage
alongside it. Record restore/setup, build, and save when measured; arbitrary phase
subdivisions are unnecessary. Unrelated dependency installation, runner queue,
verification, and complete job duration remain context. When upstream combines
them, use a reviewed boundary or label the combined measurement. Never call it
compile time or subtract guessed dependency-install durations.

Canonical phase JSON includes case, series ID and sample, provider, lane/phase,
exact source, runner environment, verified output checks, primary measurement and
scope, storage with its measurement source, and evidence links. The canonical
Ruby reporter keeps legacy phase and lane fields for existing consumers. Series
records add explicit comparison fields; legacy records without them cannot
support a new series claim.
The phase verification flag confirms output checks preceding that record.
`verification.declared_checks` lists the case's requirements; it does not claim
that checks for later phases have already run. Preserved job logs establish the
executed checks. Earlier imported records retain their original fields.

```sh
bin/bench record <case-id> --series screening-01 --record /tmp/phase.json
```

Recording rejects duplicate slots. Reporting checks matched source, case, variant,
and runner environment across provider pairs. It reports every declared
observation, missing slots, medians, ranges, and measured storage counts. Missing
storage stays unmeasured. Reports require publication review.
Correctness proofs retain successful observations and execution checks without
a numeric correctness median or provider-comparison status. A storage comparison
uses the declared provider byte measurement for its primary median and range.
Aggregate reporting retains suspected runner-variance samples and attaches its
diagnostic evidence. A variance flag does not establish the cause of a slow or
fast run and must not remove its timing from the comparison.
When review finds a measurement or fairness issue, keep the original plan and
records. Add `methodology-review.json` beside the series plan with
`schema_version: 1`, the exact `plan_sha256`, nonempty `issues`, and HTTPS
`evidence_links`. Reporting and the catalog retain all observations and mark the
series ineligible for a comparative claim. A corrected definition needs a new
series before execution; an old successful run must not acquire a revised scope.
Provider-reported bytes describe the selected cache, not total workspace usage
or billable storage. The BoringCache probe uses exact resolved tags and its
reported KV or archive size; the GitHub probe uses the selected cache key's
reported archive size. Keep those sources explicit. Do not infer equivalent
compression, cross-tag deduplication, or physical storage efficiency from these
counts alone.
Check coverage against the selected cache profile. For a combined Docker and
tool-cache profile, Docker-tag bytes alone do not establish total selected-profile
storage. State the measured subset in the interpretation and retain any missing
coverage; do not infer additional product tags in the harness.
GitHub storage reporting receives the read-only token only in the reporting step.
The selected exact-key rows are retained with their cache IDs, refs, versions,
timestamps, and byte fields. A missing row or byte field remains unmeasured;
an explicit zero-byte row is measured zero.
The selected storage total requires byte measurements for every resolved tag.
A partial probe retains its measured subtotal and unmeasured tags in
`storage_breakdown`; `storage_bytes` remains unmeasured. A missing tag or byte
field must not become a zero-byte measurement or a complete selected-cache total.
The breakdown retains the selected probe rows' status, identity, cache type, and
byte fields so coverage can be checked later. Archive entries use their archive
byte fields; an unrelated KV observation must not replace the archive size.
`action.trust_state` preserves the product's requested and resolved policy,
write permission, and decision source. Preserve the raw Action evidence as well;
do not infer publication permission from a successful build or a cache hit.

## 6. Preserve and review

```sh
bin/bench preserve --repository boringcache/benchmarks --run <run-id> --directory /tmp/evidence-<run-id>
bin/bench verify-evidence --directory /tmp/evidence-<run-id>
bin/bench collect <case-id> --series screening-01 --sample 1 --directory /tmp/evidence-<run-id>
```

`collect` checks the verified export against the retained dispatch, imports the
original phase artifacts, checks completion, and regenerates the report. It
rejects conflicting records before importing them and can resume an identical
import. It never derives missing phase measurements from logs. `record`, `finish`,
and `report` remain available separately for reviewed historical imports.

Publish the verified bundle to durable storage with a stable link. Experimental
cache retention is not permanent evidence retention. The exporter includes all
available attempts and records gaps; partial exports remain partial. Keep
original execution URLs as provenance.
Cancelled requests remain in their original series. A run cancelled before any
jobs start can have a valid empty log ZIP and a complete scoped export, with no
measurements. Empty logs for a run that has jobs remain an evidence gap. Use a
new series after correcting an execution contract; do not replace the old request
or infer phase measurements from its logs.
`finish` checks the preserved run and job conclusions and post-step logs. A
green job with a reported BoringCache post-step failure remains unqualified.
Reports require a completion check for every run represented by their phase
records; complete timing records alone cannot qualify a comparison.
Retain the raw phase and product evidence when a later reporting step fails.
Summary artifact paths and names must include the reporter's selected variant
and lane. `scripts/check-report-contract.rb` checks that naming contract.

Review correctness, matched arms, storage semantics, sample completeness,
environment variance, and claim limits. Parity and no material improvement are
valid outcomes. Promotion changes metadata or suite membership. Website claims
link to specific reports and preserved evidence, not only the homepage.

The legacy `data/latest/` collector remains a historical compatibility feed.
It reads original execution repositories and does not mix central Actions
summaries into those windows. Publish a central series through its canonical
report after evidence and methodology review; update the website's reviewed
evidence selection to an immutable report link. A green workflow or a case's
existing publication status does not approve a new series. Replacing the legacy
feed requires a separately qualified adapter for canonical series reports.

Canary monitoring follows `canary_location` in `suites/published.json`. Keep it
`historical` while the original repository owns the schedule. Set it to `central`
only when its central dispatcher and receipt have been qualified and its old
schedule retired. Missing, stale, or failed executions remain failures; importing
a definition does not move its active schedule.

Generate the common series catalog after recording or completing an evaluation:

```sh
bin/bench catalog
```

`data/latest/series.json` indexes every declared series through the same report
validator and calculations. It includes planned, requested, incomplete, failed,
completed, and invalid series, their sample counts, measurements, original runs,
completion errors, and scoped archive links. Requested means a dispatch receipt
exists; this offline catalog does not assert that GitHub queued or started a job.
Missing or stale stored reports are identified without rewriting them. Run
`bin/bench report <case-id> --series <series-id>` to generate the report after
reviewing new records. Catalog generation does not approve publication or merge
central observations into historical reporting windows.

## 7. Review source updates

Use `bin/bench sync <case-id> --output /tmp/<case-id>-source-proposal.json` in a
disposable harness checkout, or the manual `source-sync.yml` workflow. It inspects
the declared upstream branch, fetches the observed revision, checks fast-forward
history and recipe fidelity, and produces a proposal. A passing source proposal
does not verify the new build.

For verified source pairs, keep the candidate source environment from the proposal,
run its required build and output checks, then use `bin/bench update-source
<case-id> --directory <verified-candidate>` to update the reviewed pins. Create a
new series whenever the frozen definition changes. Retain the prior series and
its evidence.

Changed-source comparisons must declare the exact seed and destination revisions
and prove the intended cache continuity. Repeating one frozen source revision
does not establish changed-source performance. Legacy rolling workflows remain
diagnostic until their source sequence, seed lineage, and central caller have
been qualified. Do not enable their schedule or promote their timing merely
because the workflow completed. The series reporter keeps rolling observations
but marks them invalid for comparison while seed lineage is unsupported.

## 8. Review product updates

The immutable `boringcache/one` pin in `.github/actions/boringcache/action.yml` is
the only maintained product Action pin. Its released default owns the ordinary
CLI version. Use the existing runtime `cli_version` input for an exact release or
canary experiment; do not add separate version constants to case actions.

For an Action or CLI update, read the released Action metadata and public plan
contract, update the one pin when needed, then run the case, workflow, report,
and product-owned interface checks. Start new screening series for affected
adapters from a committed ref. Inspect output correctness, trust state, raw final
evidence, native errors, storage coverage, and post-step completion before
switching scheduled callers. A package download or passing schema check alone
does not qualify the new product version.

Keep previous series, pins, and observations unchanged. New fields in product
evidence must survive in the raw artifact even before the canonical reporter
uses them. Update the shared reporter when measurement semantics change, and
retain explicit unknown or unmeasured values. Fix missing product capabilities
in the product; do not reproduce its installers, cache identity, proxy lifecycle,
or internal evidence normalization in individual benchmark cases.
