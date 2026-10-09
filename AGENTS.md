# Benchmarks agent guide

This repository benchmarks BoringCache against other cache providers on real projects. It reports numbers only: timed phase, storage and machine, with no commentary. File formats are in [tools/README.md](tools/README.md); this file is the procedure to follow every time.

## Rules every change keeps

- Every lane of a case runs the same build command on the same source commit. Lanes differ only in their documented cache setup.
- Every lane caches the same content: dependencies and build outputs. If one lane restores a dependency store, all do.
- Use each provider's official, documented setup. Cite the doc in the commit when adding or changing a lane. Never spoof events or patch around a provider bug; record the failure instead.
- BoringCache plans set `fail-on-cache-error = true`.
- Base lanes build upstream unmodified. Overlays exist only for `plus` capabilities (tool cache, mount cache) or when upstream cannot build in CI; generate them from upstream at `start_sha` with the smallest diff.
- A lane only receives the secrets it lists. Upstream code never gets extra credentials.
- Pin every action by commit SHA and every downloaded binary by version and checksum.
- No comments in code, no attribution lines in commits.

## Add a case

1. **Source.** Pick the upstream repository and branch. `start_sha` is the latest first-parent commit on that branch when the case is added; its fresh run and rolling series start from there. Prefer the project's own CI build command and target; when it has none for this tool, use its documented build.
2. **Files.** Create `tools/<tool>/<case>/case.toml` (repo, branch, `start_sha`, untimed `prepare`, output `check`, `[runs]`) and `.boringcache.toml` (base plan). Add `plus/.boringcache.toml` only when the tool has a `plus` level that applies.
3. **Lanes.** Reuse `tools/<tool>/lanes/*.toml`. Add a lane only for a provider with documented setup. Phase behaviour: cold and rolling write, warm reads only; anything that forces a cold (for example `--remote_accept_cached=false`) stays under `[cold]`.
4. **Runners.** Default to `github`. Add other runners per case on purpose. Remote builder lanes set `machine` so labels and records name the builder, not the runner.
5. **Shared pieces.** If a second case needs the same helper, move it to `tools/<tool>/shared/`, or `tools/shared/` when cases of several tools need it, and call it with `$BENCH_ROOT/...`. Never copy a helper between cases.
6. **Check locally.** `bundle exec bin/bench check`, the tests (see below), `bin/bench matrix <project> --tool <tool>`, and a local `bin/bench run` when the tool runs on this machine.
7. **Check on Actions.** Preflight, then a fresh run:
   `gh workflow run project.yml --ref main -f tool=<Tool> -f project=<project> -f mode=preflight`, then `-f mode=fresh`.
8. **Audit the fresh run.** Every record has `exit_status` 0 and `output_ok` true, each warm follows a passing cold, and logs show the cache restored and saved. A failed cold means its warm is not a comparison.
9. **Roll.** Add the project to `rolling.toml` only after its fresh run passes.

## Run and roll

- Fresh runs build `start_sha` cold then warm. A cold cannot be retried inside a run; dispatch a new fresh run.
- Rolling keeps one position per tool and project. Every lane builds the same next first-parent commit, and the next run moves on whether or not that commit failed. Projects without new upstream commits plan nothing.
- Each lane rolls on one fixed cache scope, `<lane>-<runner>-rolling`, which every step restores and saves. Fresh runs use their own run-scoped caches and never touch it, so a lane's first rolling step starts empty.
- `schedule.yml` dispatches rolling for every project in `rolling.toml`; the workflow's concurrency group runs one rolling run per project at a time.
- A failed build or output check is recorded first, then fails its job. A failure in `prepare` leaves no record; that lane continues at the next step.
- Re-run a failed rolling job only before the next step of that project starts. A re-run of an older step skips its build once a newer step is recorded for that lane, so it can never overwrite the newer cache.

## Test a CLI canary

`versions.toml` pins the released CLI for every run. To check a fix before release, run a fresh run of the affected lanes with a published canary:

```sh
gh workflow run project.yml --ref main -f tool=<Tool> -f project=<project> -f mode=fresh -f lane="<lanes>" -f cli=vcli-canary-<sha>
```

- Confirm the canary contains the fix first: `git -C monorepo merge-base --is-ancestor <fix-commit> <canary-sha>`.
- Canary records carry `versions.boringcache_release`, and the report shows that tag in the CLI column, so they never merge with release rows. Compare them with the release fresh rows at the same commit.
- Rolling always uses the pinned CLI. Bump `versions.toml` only after the release is published.

## Investigate a failure

Classify it before changing anything:

- **Harness** (prepare, wiring, workflow): fix it here with a test.
- **BoringCache product**: note the run and evidence, and fix it in `monorepo`. Leave the lane failing until a released CLI carries the fix.
- **Other provider**: keep the lane failing and note it. If the provider cannot run the case, remove the lane and log the outcome under "Removed lanes" in `PLAN.md` with run links.
- **Upstream** (their build or a transient download): record it and keep rolling.

## Checks

Run tests the way CI does, so ambient GitHub variables cannot change results:

```sh
GITHUB_ACTIONS=true GITHUB_RUN_ATTEMPT=1 bundle exec ruby -Ilib -e 'Dir["test/bench/*_test.rb"].each { require_relative it }'
bundle exec bin/bench check
actionlint .github/workflows/*.yml
```
