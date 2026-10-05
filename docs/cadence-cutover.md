# Cadence cutover

The new workflows are merged, but central activation is off. The user deferred
activation until a compatible stable CLI is released. Historical cron triggers
remain active. Do not apply the prepared patches or set the activation variable
before the release and qualification gates in [cadence.md](cadence.md) pass.

The [October 5 inventory](../migration/cadence-schedule-inventory-2026-10-05.json)
records 48 scheduled workflows in the 17 historical repositories represented by
the maintained suite. It records the default branch, observed head, workflow
blob SHA, cron expressions and remaining entrypoints. The seven snapshot cases
have no replaced BoringCache repository schedules.

[Prepared patches](../migration/cadence-cutover-patches) remove only each
inventoried workflow's `schedule` event. Each edited document was parsed and
compared with the original after removing that event; manual and PR events, jobs,
permissions and other workflow behavior remain equivalent. These patches have
not been applied. Unselected repositories, including Docker corpus, are outside
this cutover.

When release and qualification are complete:

1. Resolve the exact stable CLI and run the full 31-target dry run on `main`.
   Require the REAPI capability check to pass without omissions or substitution
   of a canary. Confirm hosted checks and the retained qualification records.
2. Refresh the historical inventory. Review any changed workflow blobs before
   applying their patches. Keep central activation off while removing all 48
   historical cron triggers. Preserve their manual and PR entrypoints.
3. Query every historical repository for queued, pending and running scheduled
   or source-dispatched work. Allow those runs and downstream requests to finish;
   retain their run IDs. Recheck that no replaced cron triggers remain. Do not
   cancel unrelated runs or treat a stopped scheduler as a drained queue.
4. Set `BENCHMARK_CADENCE_ACTIVE=true` in `boringcache/benchmarks`. This transfers
   source checks, weekly/nightly dispatch and canary monitoring to the central
   suite. The first hourly source check should produce per-case observations;
   changed cases should retain intent and requested run IDs independently.
5. Verify the first complete source cycle and the first weekly and nightly
   dispatches. Compare each receipt with the 24-case / 31-fresh-target inventory,
   then inspect leaf outcomes and comparison reports. Request acceptance alone
   is not build completion.

If central ownership must be stopped, unset the activation variable first and
inspect already requested central runs. Restore historical cron triggers only
after central requests have drained, so both owners do not request the same
work. Retain source receipts and observations during either transition.
