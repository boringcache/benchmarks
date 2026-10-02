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
Archiving does not preserve expiring Actions evidence. Missing evidence and
unverified execution remain explicit in the inventory.

llama.cpp run `36902057374` has a verified export of its listed attempt, logs,
artifacts, commit, and workflow. The [archived bundle](https://github.com/boringcache/benchmarks/releases/tag/evidence-llama-cpp-36902057374)
was downloaded after upload, checked against its SHA-256, extracted, and verified
against its run inventory. `migration/evidence.json` records that verification.
This scoped export is not a completeness audit of the fork.
