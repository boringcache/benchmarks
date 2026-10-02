# Consolidation acceptance

The first cutover migrates the 18 maintained `benchmark-*` repositories:
17 benchmark cases and Docker's 47 pinned workloads. Fork evaluations are deferred
in `migration/forks.json`. Original forks and benchmark repositories remain
unchanged until verification.

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
GitHub's default CodeQL configuration now scans Ruby and Actions. Python was
removed from its language list because this branch removes the maintained Python
reporter; query suite, threat model, weekly schedule, and runner settings were
preserved.
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

The legacy index collector continues to read the original execution repositories.
It cannot publish raw central Actions summaries or mix them into historical
windows. New central claims use reviewed canonical series reports. Migrating the
legacy index to those records remains a reporting cutover gate.

The gRPC case declares its BuildBuddy arm alongside BoringCache and Actions Cache,
so a series cannot omit the third provider's observations. Its credential is
passed only to BuildBuddy matrix jobs. The existing organization secret is
restricted to `benchmark-grpc`; central access must be configured before gRPC
qualification or caller cutover.
