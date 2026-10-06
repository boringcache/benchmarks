# Benchmark schedules

`boringcache/benchmarks` owns execution and monitoring. The retired execution
repositories are archived. Historical run URLs and exported evidence retain
their original repository identity.

`suites/scheduled.json` selects 24 source cases, 32 case/variant selections and
34 underlying fresh workers. Project dispatch groups variants and provider
workflows into 22 project runs. The 47-workload Docker corpus and prospect drafts
are excluded from scheduling.

| Cadence | UTC schedule | Source |
| --- | --- | --- |
| Fresh | Monday 04:00 | Declared pins |
| Nightly | Daily 01:17 | Declared pins; cold and identical-source replay, or declared changed-source phases |
| Rolling | Hourly source check at :11 | New upstream commits that pass recipe inspection |
| Monitor | Hourly at :47 | Both scheduled cadences and rolling receipts |

All cadences use the exact published canary in [`config/cli.json`](../config/cli.json).
The provider wrapper and direct CLI workers use that same default. Changing the
reviewed pin changes the execution definition; earlier series retain their
original selector. A compatible stable release can replace this pin later.
`BENCHMARK_CADENCE_ACTIVE=true` enables automatic dispatch and source publication.
Manual dispatch and dry runs remain available. Scheduling, monitoring and publication
are currently paused for the reset. Rolling cache scopes are explicit and remain
stable across harness refs. Each rolling series begins with a seed build, then an
identical-source replay, before advancing to changed-source builds.

## Runs and evidence

Run names show the project, cadence and CLI selector. Providers, native tools and
variants appear inside the project run. n8n's four workloads, Mastodon's selected
Docker/compiler/streaming workloads, PostHog's profiles, Storybook's archive and
Nx workloads, and OBS's provider/tool arms each share their project's run. Hugo's Go and Docker
workloads share one run; Zed's Cargo and Nix workloads share one run. Rolling
source inspection batches changed tool cases from the same upstream project
into one dispatch while preserving each case's source and promotion contract.
Fresh and Nightly are distinct cadences; their measured phases retain the fresh
lane. Rolling remains a changed-source observation.

Preflight validates the whole suite, resolves one exact CLI and freezes a
one-sample series for each case and variant. Grouping preserves those plans,
provider sets, tags and series identities. Actual batches dispatch against an
immutable `benchmark-<parent-run-id>` ref pointing to the frozen harness commit;
source and data commits on `main` cannot change that batch. Dry runs create no ref. Each fresh sample is independent;
its warm jobs depend on its own seed. Rolling publication is ordered by cache
identity, with `queue: max` and no cancellation of an existing observation.
gRPC provider jobs have a 120-minute budget in both lanes.

The monitor checks the configured CLI selector, receipt freshness, executed
harness identity, expected provider/phase slots and canonical record validation.
GitHub success without required phase evidence fails monitoring. Native Nx warm
compilation without observed cache reuse also fails monitoring. Native fresh
reports also retain failed, cancelled and skipped jobs, including post-step
failures. A verified output does not override a failed job. Rolling diagnostic
records without a frozen series remain labelled diagnostic; they do not acquire
a new comparative plan during collection.

[`data/latest/current.json`](../data/latest/current.json) contains current central
receipts and measurements. [`data/observations/`](../data/observations/) retains
observations by cadence and run ID, including pending and failed work. The
existing [`series catalog`](../data/latest/series.json) retains declared manual
and imported series. Publication on the product website remains a separate
review. Pre-reset measurements and receipts have been removed. The monitor filters parent
runs and rolling receipts against the cutoff in `config/baseline.json`; publication
rejects outcomes from another baseline.

Storage probes run after publication. Original product and phase JSON remain
retained; a separate measurement joins by run, attempt, workspace and exact
resolved tags. Actions archive sizes are read after explicit cache save.
Cachix records provider-reported compressed NAR sizes for the selected runtime
closure. bazel-remote records its uncompressed local AC/CAS store after shutdown;
that does not measure the compressed remote archive. NativeLink records scoped
R2 object sizes. Missing measurements remain unmeasured. BuildBuddy and GitHub
Docker blob attribution still lack complete storage measurements.

## Upstream changes

Each upstream project has one source-controller lock. Recipe inspection runs
with read-only permissions; a separate publisher applies only reviewed source
pin changes using a conditional commit. It preserves dispatch intent before
requesting builds and retains candidate history under `migration/rolling/`.
When several tool cases change, one conditional commit retains all their intents
before the shared dispatch. An uncertain dispatch blocks every affected case.

The next cycle reconciles requested runs and their output evidence before
advancing again. Uncertain dispatches block automatic retries. Unchanged sources
request no build. Recipe changes remain blocked until reviewed; the controller
does not update their digests automatically. Zed additionally requires a verified
build before promoting its source. Failed observations remain retained.
