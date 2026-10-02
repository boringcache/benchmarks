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

For the standard BoringCache/Actions Cache comparison, use
`native-fresh-benchmark.yml` and `native-rolling-benchmark.yml`. Declare the local
composite action, benchmark ID, toolchain inputs, and lane-specific publication
settings in `execution.native`. Register `case_id` in the workflow inputs. The
shared executor prepares that reviewed action on the disposable runner; agents
do not copy workflow setup or reporting into each new case. Declare tag mappings
in `execution.cache_tags` and use `scope-case-cache.rb`. Use `prepare-source.rb`
for an unchanged pinned upstream checkout.

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
Docker tool caches remain product-plan settings rather than a second implementation
of the product's proxy or cache lifecycle.
Cache errors always fail benchmark observations. The wrapper sets that policy
literally and converts the optional cache-miss input to a boolean expression.
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

Fresh series declare either a cold build and identical-source replay, or a cold
parent seed and changed-source build. The workflow's `phases` declares the latter
as `["cold", "commit"]`; it must never be labelled an identical-source warm replay.
Rolling series contain changed-source commit observations and retain the parent cache seed.
Identities include case and series. Cases share a workspace but must not share
cold cache identity accidentally.

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

Use `bin/bench run <case-id> --series <series-id> --sample 1` for a registered workflow.
Repeat with the next declared sample number. Use `--workflow <filename>` when a
case has more than one execution path. A receipt is retained for each sample and
workflow; a changed case requires a new series. Use `--variant` at series creation
when measuring a particular workload variant.
Workflows that declare `variants` require one of those variants at series creation.
The Zed layer proof uses the same combined cold seed for its target-only,
sccache-only, and combined restore probes; it establishes output correctness and
cache behavior rather than a comparison between providers.
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
Aggregate reporting retains suspected runner-variance samples and attaches its
diagnostic evidence. A variance flag does not establish the cause of a slow or
fast run and must not remove its timing from the comparison.
Provider-reported bytes describe the selected cache, not total workspace usage
or billable storage. The BoringCache probe uses exact resolved tags and its
reported KV or archive size; the GitHub probe uses the selected cache key's
reported archive size. Keep those sources explicit. Do not infer equivalent
compression, cross-tag deduplication, or physical storage efficiency from these
counts alone.

## 6. Preserve and review

```sh
bin/bench preserve --repository boringcache/benchmarks --run <run-id> --directory /tmp/evidence-<run-id>
bin/bench verify-evidence --directory /tmp/evidence-<run-id>
bin/bench finish <case-id> --series screening-01 --sample 1 --directory /tmp/evidence-<run-id>
bin/bench report <case-id> --series screening-01
```

Publish the verified bundle to durable storage with a stable link. Experimental
cache retention is not permanent evidence retention. The exporter includes all
available attempts and records gaps; partial exports remain partial. Keep
original execution URLs as provenance.
`finish` checks the preserved run and job conclusions and post-step logs. A
green job with a reported BoringCache post-step failure remains unqualified.
Reports require a completion check for every run represented by their phase
records; complete timing records alone cannot qualify a comparison.

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
