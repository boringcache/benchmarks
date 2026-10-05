# Benchmark schedules

The schedule migration is incomplete. Historical repositories still own the
active weekly, canary and upstream-sync schedules. Do not enable duplicate
central schedules before removing the corresponding historical triggers.

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

Source checks currently retain proposals only. An unchanged source is recorded
as unchanged; a recipe mismatch or fixed source is recorded as blocked. A later
failure does not remove earlier case checks. The workflow does not commit source
changes, promote candidates or start rolling builds.

## Work remaining before schedule migration

- Connect reviewed source advancement to rolling dispatch and retain the exact
  parent source, cache seed and requested run. Skip unchanged sources. Preserve
  failed observations and serialize updates to each rolling cache.
- Add and qualify rolling paths for Immich, Mastodon, PostHog, n8n and OBS. Their
  existing diagnostic paths do not establish the current comparison contract.
- Add and qualify source advancement and rolling paths for the seven new REAPI
  and Nix cases. Their successful cold/warm screens use fixed source pins.
- Preserve Zed's build-verified source promotion and Deno's adjacent-commit
  sequence when moving their current source controllers.
- Run the central dispatch on GitHub, check receipts and workload completion,
  and verify the selected stable release supports each scheduled case.
- Remove replaced historical cron triggers, preserving manual and release
  entrypoints. Change monitoring and publication ownership with that migration.

The new central cron definitions are proposed configuration until this branch
is merged. Passing configuration tests does not complete the rolling or source
promotion work above.
