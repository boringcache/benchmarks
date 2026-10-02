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

Add reviewed dispatchable workflows in `.github/workflows/` and register paths and
inputs in the case. Use shared preparation and the canonical Ruby reporter. Add
suite membership for an explicit scheduling purpose. `suites/published.json` is
the shared registry for published reporting.

## 3. Validate before execution

```sh
bin/bench check <case-id>
bin/bench plan <case-id> --lane fresh
bin/bench prepare <case-id> --directory /tmp/<case-id>-workload
```

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

```sh
bin/bench record <case-id> --series screening-01 --record /tmp/phase.json
bin/bench report <case-id> --series screening-01
```

Recording rejects duplicate slots. Reporting checks matched source, case, variant,
and runner environment across provider pairs. It reports every declared
observation, missing slots, medians, ranges, and measured storage counts. Missing
storage stays unmeasured. Reports require publication review.

## 6. Preserve and review

```sh
bin/bench preserve --repository boringcache/benchmarks --run <run-id> --directory /tmp/evidence-<run-id>
bin/bench verify-evidence --directory /tmp/evidence-<run-id>
```

Publish the verified bundle to durable storage with a stable link. Experimental
cache retention is not permanent evidence retention. The exporter includes all
available attempts and records gaps; partial exports remain partial. Keep
original execution URLs as provenance.

Review correctness, matched arms, storage semantics, sample completeness,
environment variance, and claim limits. Parity and no material improvement are
valid outcomes. Promotion changes metadata or suite membership. Website claims
link to specific reports and preserved evidence, not only the homepage.
