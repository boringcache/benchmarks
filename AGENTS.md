# Benchmarks agent guide

This repository benchmarks BoringCache against other cache providers on real projects. It reports numbers only: timed phase, storage and machine, with no commentary. File formats are in [tools/README.md](tools/README.md); this file is the procedure to follow every time.

## Rules every change keeps

- Keep benchmark measurements, outcomes, reproducible configuration and customer-accessible CLI/action logs here. Do not commit internal investigation notes, private operations details or server-side MCP snapshots.

- Every lane of a case runs the same build command on the same source commit. Lanes differ only in their documented cache setup.
- Every lane caches the same content: dependencies and build outputs. If one lane restores a dependency store, all do.
- Use each provider's official, documented setup. Cite the doc in the commit when adding or changing a lane. Never spoof events or patch around a provider bug; record the failure instead.
- BoringCache plans set `fail-on-cache-error = true`.
- Base lanes build upstream unmodified. Overlays exist only for `plus` capabilities (tool cache, mount cache) or when upstream cannot build in CI; generate them from upstream at `start_sha` with the smallest diff.
- A lane only receives the secrets it lists. Upstream code never gets extra credentials.
- Pin every action by commit SHA and every downloaded binary by version and checksum.
- No comments in code, no attribution lines in commits.

## Add a case

1. **Source.** Pick the upstream repository and branch. `start_sha` is the latest first-parent commit on that branch when the case is added; its rolling series starts there. Prefer the project's own CI build command and target; when it has none for this tool, use its documented build.
2. **Files.** Create `tools/<tool>/<case>/case.toml` (repo, branch, `start_sha`, untimed `prepare`, output `check`, `[runs]`) and `.boringcache.toml` (base plan). Add `plus/.boringcache.toml` only when the tool has a `plus` level that applies.
3. **Lanes.** Reuse `tools/<tool>/lanes/*.toml`. Add a lane only for a provider with documented setup. Phase behaviour: cold and rolling write, warm reads only; anything that forces a cold (for example `--remote_accept_cached=false`) stays under `[cold]`.
4. **Runners.** Default to `github`. Add other runners per case on purpose. Remote builder lanes set `machine` so labels and records name the builder, not the runner.
5. **Shared pieces.** If a second case needs the same helper, move it to `tools/<tool>/shared/`, or `tools/shared/` when cases of several tools need it, and call it with `$BENCH_ROOT/...`. Never copy a helper between cases.
6. **Check locally.** `bundle exec bin/bench check`, the tests (see below), `bin/bench matrix <project> --tool <tool>`, and a local `bin/bench run` when the tool runs on this machine.
7. **Check on Actions.** Preflight:
   `gh workflow run project.yml --ref main -f tool=<Tool> -f project=<project> -f mode=preflight`.
8. **Roll.** Add the project to `rolling.toml` and dispatch `-f mode=rolling`. Step 0 builds `start_sha` with every lane's cache empty, so it is the cold baseline; each later step restores the step before it.
9. **Audit step 0 and step 1.** Every record has `exit_status` 0 and `output_ok` true, and logs show step 0 saving and step 1 restoring. Fresh runs (`mode=fresh`, cold then warm at one commit) are for one-off comparisons such as CLI canaries.

## Run and roll

- Fresh runs build `start_sha` cold then warm. A cold cannot be retried inside a run; dispatch a new fresh run.
- Rolling keeps one position per tool and project. Every lane builds the same next first-parent commit, and the next run moves on whether or not that commit failed. Projects without new upstream commits plan nothing.
- Each regular lane rolls on one fixed cache scope, `<lane>-<runner>-rolling`. `[samples]` reserves selected lanes for weekly `mode=sample` builds of the latest completed GitHub source commit; samples also run when upstream has no new commit and do not advance rolling. They share the project's rolling concurrency group. BoringCache samples restore the regular GitHub cache without publishing; native caches persist between samples. Fresh runs use their own scopes and exclude sample lanes. Legacy `[nightly]` behavior remains supported for historical configurations.
- When a lane, runner or rolling series leaves `[runs]`, delete its BoringCache tags with `boringcache rm --no-platform --no-git boringcache/benchmarks <tags>`, listing them by exact name. Its records stay in `results/`.
- `schedule.yml` runs `bin/bench tick` every 15 minutes. It checks each idle project in `rolling.toml` against its upstream branch and dispatches only when a commit is due at its configured stride. Active or queued rolling and sample projects wait for a later tick. An upstream check failure is reported and fails the tick without dispatching that project. The workflow's concurrency group runs one rolling run per project at a time.
- `prune-buildkit.yml` deletes stale BuildKit `type=gha` blobs every 2 hours.
- `report.yml` regenerates `data/results.json` and `data/report.md` hourly from recorded results. Experimental lanes are excluded.
- A failed build, output check or in-job Actions cache save is recorded first, then fails its job. A failure in `prepare` leaves no record; that lane continues at the next step.
- Re-run a failed rolling job only before the next step of that project starts. A re-run of an older step skips its build once a newer step is recorded for that lane, so it can never overwrite the newer cache.
- Rolling dispatches must use the tool's display title, such as `Rust/Cargo`, so manual runs share the scheduler's concurrency group.
- A job re-run uses the harness from its original commit. To re-run a recorded step with a harness fix, dispatch `-f mode=rolling -f step=<N>`: it builds that step's commit for lanes without a passing record at that step or a newer recorded step.

## Test a CLI canary

`versions.toml` owns which CLI every run installs. `boringcache` pins the released CLI for all cases, and `[cases]` maps a case id to a release or canary tag that its rolling and fresh runs install instead:

```toml
boringcache = "1.41.0"

[cases]
"cargo/ferrum-fuzz" = "vcli-canary-8bfb456f9a79"
```

To check a fix once, run a fresh run of the affected lanes with a published canary:

```sh
gh workflow run project.yml --ref main -f tool=<Tool> -f project=<project> -f mode=fresh -f lane="<lanes>" -f cli=vcli-canary-<sha>
```

- Confirm the canary contains the intended change before benchmarking it.
- Canary records carry `versions.boringcache_release`, and the report shows that tag in the CLI column, so they never merge with release rows. Compare them with the release fresh rows at the same commit.
- Pin a case in `[cases]` only when it needs an unreleased fix to roll, and remove the entry once a release with the fix is pinned. Bump `boringcache` only after the release is published.

## Investigate a failure

Classify it before changing anything:

- **Harness** (prepare, wiring, workflow): fix it here with a test.
- **BoringCache product**: retain the failed benchmark record. Investigate and fix the product outside this repository. Leave the lane failing until a released CLI carries the fix.
- **Other provider**: keep the lane failing and note it. If the provider cannot run the case, remove the lane and log the outcome under "Removed lanes" in `PLAN.md` with run links.
- **Upstream** (their build or a transient download): record it and keep rolling.
- **Not a measurement** (a build that passed while its provider served no cache, such as a lapsed plan): add `"excluded": "<reason and evidence>"` to those records, and to the next step if it restored a cache the outage never saved. The report leaves them out; the records stay.
- **Failed cache save** (`cache_save` is `failed`, or the report shows `stale restore` because a step restored an older step's cache than the lane's previous step): read the save step in the job log. A full runner disk or a provider error is **Other provider**; keep the lane failing. For post-job saves recorded before `cache_save` existed, run `GITHUB_REPOSITORY=boringcache/benchmarks bundle exec bin/bench cache-saves --results results` with `gh` signed in. It fills `cache_save` only when the job log still exists and shows the save outcome.
- **Unrecorded restore** (a rolling record with `cache_restore_tracked` but no `cache_restored_key`, as `cache-dance` lanes wrote before their restore moved to `actions/cache/restore`): with `gh` signed in, run `GITHUB_REPOSITORY=boringcache/benchmarks bundle exec bin/bench restored-keys --results results`. It fills the key only when the original job log shows that lane's restore before post-job cleanup.

## Checks

Run tests the way CI does, so ambient GitHub variables cannot change results:

```sh
GITHUB_ACTIONS=true GITHUB_RUN_ATTEMPT=1 bundle exec ruby -Ilib -e 'Dir["test/bench/*_test.rb"].each { require_relative it }'
bundle exec bin/bench check
actionlint .github/workflows/*.yml
```
