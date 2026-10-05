# Benchmark schedules

The schedule migration is incomplete. Historical repositories still own the
active weekly, canary and upstream-sync schedules. Do not enable duplicate
central schedules before removing the corresponding historical triggers.
Central scheduled jobs require the repository variable
`BENCHMARK_CADENCE_ACTIVE=true`. Manual checks remain available while it is
unset. Canary monitoring continues to inspect the historical repositories until
that same switch changes ownership.

`suites/scheduled.json` selects the maintained suite and the new Moon, Pants,
Buck2, sbt and Nix workloads. It excludes Docker corpus and prospect drafts.
The same selections feed fresh dispatch and source checks. Case definitions own
workflow paths and variant inputs; the suite does not copy them.

The proposed central cadence is:

| Run | UTC schedule | CLI | Source |
| --- | --- | --- | --- |
| Weekly fresh | Monday 04:00 | Latest published stable release, with all required assets | Declared pins |
| Nightly fresh | Daily 01:17 | Latest published canary, with all required assets | Declared pins |
| Source check | Daily 00:11 | No build | Check upstream against declared pins |

Fresh dispatch resolves one exact release tag for every selected workflow. It
validates all targets before dispatch and retains each requested run ID. A
dispatch succeeding does not establish that its builds passed. A dry run starts
no builds. Inspect the retained receipt before retrying an interrupted dispatch.
When the selection includes REAPI cases, preflight downloads the exact CLI,
verifies its release checksum, and requires `cache-registry --reapi-port` in its
command interface before dispatching any target. This check also runs in dry runs.

The October 5 capability check rejected stable `v1.33.0` before dispatch: it
does not expose `--reapi-port`. Canary `vcli-canary-7a5b27146ebe` passed the same
31-target check. Stable activation remains pending a compatible release; the
weekly caller must not silently substitute a canary or omit the new families.

Source checks currently retain proposals only. The seven new snapshot cases now
check their declared upstream branches, require fast-forward ancestry, and verify
the reviewed recipe against an exact candidate commit. Nix proposals update the
matching source URI in the plan and command contract; they do not change recipe
digests or build flags. A recipe or patch failure leaves the declared pin unchanged.
An unchanged source is recorded as unchanged; a recipe mismatch or fixed source
is recorded as blocked. A later
failure does not remove earlier case checks. The workflow does not commit source
changes, promote candidates or start rolling builds.

Immich, Mastodon, PostHog and n8n now register the shared native rolling workflow.
Their Docker variants load and inspect output in both providers. The same output
contract now applies to Hugo, Chroma, Duckgres and Linkerd2 rolling definitions,
which previously selected image publication. These definitions need live rolling
qualification; passing schema and workflow checks does not establish seed reuse.

The repository's Actions cache limit was increased from 10 GB to 200 GB on
October 5. Retention is still seven days. This provides more capacity, but does
not prove that an individual rolling seed was available or restored.

## Work remaining before schedule migration

- Connect reviewed source advancement to rolling dispatch and retain the exact
  parent source, cache seed and requested run. Skip unchanged sources. Preserve
  failed observations and serialize updates to each rolling cache.
- Qualify the registered rolling paths for Immich, Mastodon, PostHog and n8n,
  and add and qualify OBS rolling. Their existing diagnostic paths do not
  establish the current comparison contract.
- Qualify source advancement and add rolling paths for the seven new REAPI and
  Nix cases. Their successful cold/warm screens use fixed source pins.
- Preserve Zed's build-verified source promotion and Deno's adjacent-commit
  sequence when moving their current source controllers.
- Run the central dispatch on GitHub, check receipts and workload completion,
  and verify the selected stable release supports each scheduled case.
- Remove replaced historical cron triggers, preserving manual and release
  entrypoints. Change monitoring and publication ownership with that migration.

After a compatible stable release and qualification, remove replaced historical
cron triggers, verify there are no outstanding duplicate dispatches, then set
`BENCHMARK_CADENCE_ACTIVE=true`. Merging this branch alone does not activate the
central jobs. Passing configuration tests does not complete the rolling or
source promotion work above.
