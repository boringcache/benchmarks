# Benchmark measurements

The main results table has one row per lane, runner, phase, step, commit, CLI version, attempt, save timing and observed CPU. Its timings exclude failed builds, failed or missing output checks, warm records without a passing cold record in the same scope, and rolling steps that restored nothing from the lane's Actions cache after the lane's first step ("Seed failed"). "Cache API errors" copies the error count from the CLI session summary. Customer-accessible CLI/action logs remain benchmark evidence. Internal investigation notes and server-side MCP snapshots are excluded.

The second table, "Matched rolling steps", compares lanes only at the rolling steps where every lane on a runner passed, grouped by rolling series and the BoringCache CLI version of that step. A lane's first step on its rolling cache starts empty, so it is left out. "Steps with cache API errors" counts the matched steps whose BoringCache session reported errors. Failed attempts remain evidence, and a rerun attempt is recorded next to the first one.

Two harness fixes on 2026-10-08 (UTC) bound which rolling records compare:

- Before `144b6ddd` (18:25), Actions cache lanes restored the fresh run's seed instead of the previous step whenever that seed was still cached. Records from 18:37 carry `cache_restored_key`, the key the lane restored.
- Before `db639cbad` (21:27), a lane whose fresh cold had passed continued on that fresh run's cache scope; those records have `cache_seeded = true` ("From fresh run" in the report). Every lane then moved to one fixed scope, `<lane>-<runner>-rolling`, starting empty at its next step.

The matched table leaves out records continued from a fresh run's scope, Actions cache steps that restored nothing, post-job saves whose time was not measured, and runners with only one lane. Records from before `144b6ddd` on a fixed scope carry no `cache_restored_key`, so check their dates. `harness.commit` names the benchmark commit that produced a record, and `harness.timer` what its `seconds` covers.

`seconds` runs from `bin/bench start`, after checkout, preparation and the BoringCache CLI download, to `bin/bench record`: the lane's cache restore, the build and the lane's in-job cache save. It excludes the output check and is not the full job duration. Kache, mr-boxington, the BuildKit cache dance and Namespace cache volumes save in post-job steps after the record is written; the publish job reads those steps' durations from the job log into `post_job_save_seconds`, and the report adds them to the timing. The kache and mr-boxington actions also install their tool after the timer starts, which took under a second in Zed run 37994555454, about the time of the BoringCache CLI download.

Cold starts with a fresh local workspace. Providers with shared remote caches may still have existing data unless the lane isolates the cache or disables reads. Runner labels also do not guarantee identical CPUs. Each record stores the machine it ran on and the CPU it observed. Remote builder lanes (Depot and Namespace builders) record the builder as their machine; the CPU they observe is the calling runner's, so it is kept as `observed.runner_machine`, and the builder's own hardware is not recorded. Check the lane configuration and recorded machine before interpreting a timing difference.

`base` and `plus` describe declared cache capabilities. They are separate comparisons; a compiler-cache-only lane does not promise the same reuse as a lane that also restores the build directory.

Experimental lanes are excluded from the report. A matched step must use the same source commit in every included lane. Lanes with failed or missing measurements still count toward the required comparison set after their first recorded step.

New Actions records set `cache_restore_tracked` when the harness ran an Actions cache restore. A missing key after that scope's first step is a seed failure even if the scope has never restored successfully. Older records lack that distinction; the report identifies their restoring scopes from successful restored keys. Providers without a tracked restored key cannot be classified by this field.

## Runner samples

Weekly and manual samples appear as individual runs in `samples` and the Runner samples table, apart from rolling medians. Rows retain source commit, cache source, observed CPU and cores, timed operations, exit status and output check. Missing post-job timing is unmeasured, not zero. The selected GitHub source run is metadata for a mutable cache tag, not an immutable version identifier.

BoringCache samples restore the completed GitHub commit's cache without saving. Native Depot, Namespace and Blacksmith caches retain their own history and include saving. These are different usage patterns; their elapsed-time difference is not a controlled cache-provider speedup. GitHub and third-party BoringCache samples within one dispatch use the same commit, scope and operations. Machine allocation can still vary. See [the runner and dependency procedure](../tools/README.md#weekly-runner-samples) for schedules and remaining resource differences.
