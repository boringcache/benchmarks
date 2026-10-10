# BoringCache benchmarks

Build real projects with BoringCache and other cache providers. Each result identifies the source revision, provider, runner, machine, phase, and GitHub Actions run.

The repository contains the benchmark definitions and workflows. Earlier `benchmark-*` repositories are archived; their historical results remain separate from this harness.

## Layout

```text
tools/<tool>/
  tool.toml                 tool and cache capability levels
  lanes/<lane>.toml         provider setup and phase behavior
  <project>/
    case.toml               source pin, preparation, checks, and runner matrix
    .boringcache.toml       build command and BoringCache configuration
    plus/.boringcache.toml  optional plan with additional cache capabilities
lib/bench/                  shared benchmark runner
.github/actions/phase/      GitHub Actions setup and phase execution
.github/workflows/          project runs, rolling dispatch, and checks
results/                    recorded runs and retained evidence
```

A tool can contain several cases for one project. Each case lists the provider lanes and runners to compare. See [tools/README.md](tools/README.md) for the configuration format.

## Run

Use the Ruby version in `.tool-versions`, then install dependencies and validate the catalog:

```sh
bundle install
bundle exec bin/bench check
bundle exec bin/bench list
bundle exec bin/bench matrix grpc --tool bazel
```

Start a fresh comparison on GitHub Actions:

```sh
gh workflow run project.yml --ref main -f tool=Bazel -f project=grpc -f mode=fresh
```

`mode=fresh` runs cold and then warm on separate runners. Both build the same pinned commit. Cold seeds the cache; warm measures reuse. A cold phase cannot be rerun under the same run ID; start another fresh run instead.

`mode=preflight` runs the setup and probes declared by each lane. An empty probe list does not verify credentials or build compatibility.

`mode=rolling` follows first-parent upstream commits from the case's `start_sha`, one commit per run for each tool and project. Every lane of the project builds the same commit, and the next run moves on whether or not that commit failed; failed commits stay recorded and can be rerun. `rolling.toml` selects projects for `schedule.yml`, which is dispatched manually.

Add `-f lane=<lane>` to run only some lanes, for example while debugging one provider.

A failed build or failed output check is recorded first, then fails its job. Other lanes keep running.

For local setup checks:

```sh
bundle exec bin/bench run bazel/grpc --lane boringcache-bazel
bundle exec bin/bench image
bundle exec bin/bench run bazel/grpc --lane boringcache-bazel --container
```

Local runs need the lane's tools and credentials. Container runs read credentials from `.env` by default; keep that file out of Git. Direct local runs can retain caches outside the work directory and should not be compared with fresh CI runners.

## Read results

```sh
bundle exec bin/bench report --results results --out tmp/report
```

The report has two tables. The first has one row per lane, runner, phase, step, commit, CLI version, attempt, save timing and observed CPU. Its timings exclude failed builds, failed or missing output checks, warm records without a passing cold record in the same scope, and rolling steps that restored nothing from the lane's Actions cache after the lane's first step ("Seed failed"). "Cache API errors" copies the error count from BoringCache's session summary; the build can pass while its cache uploads failed, as when the workspace reached its storage cap on 2026-10-08 (see `PLAN.md`).

The second table, "Matched rolling steps", compares lanes only at the rolling steps where every lane on a runner passed, grouped by rolling series and the BoringCache CLI version of that step. A lane's first step on its rolling cache starts empty, so it is left out. "Steps with cache API errors" counts the matched steps whose BoringCache session reported errors. Failed attempts remain evidence, and a rerun attempt is recorded next to the first one.

Two harness fixes on 2026-10-08 (UTC) bound which rolling records compare:

- Before `144b6ddd` (18:25), Actions cache lanes restored the fresh run's seed instead of the previous step whenever that seed was still cached. Records from 18:37 carry `cache_restored_key`, the key the lane restored.
- Before `db639cbad` (21:27), a lane whose fresh cold had passed continued on that fresh run's cache scope; those records have `cache_seeded = true` ("From fresh run" in the report). Every lane then moved to one fixed scope, `<lane>-<runner>-rolling`, starting empty at its next step.

The matched table leaves out records continued from a fresh run's scope, Actions cache steps that restored nothing, post-job saves whose time was not measured, and runners with only one lane. Records from before `144b6ddd` on a fixed scope carry no `cache_restored_key`, so check their dates. `harness.commit` names the benchmark commit that produced a record, and `harness.timer` what its `seconds` covers.

`seconds` runs from `bin/bench start`, after checkout, preparation and the BoringCache CLI download, to `bin/bench record`: the lane's cache restore, the build and the lane's in-job cache save. It excludes the output check and is not the full job duration. Kache, mr-boxington, the BuildKit cache dance and Namespace cache volumes save in post-job steps after the record is written; the publish job reads those steps' durations from the job log into `post_job_save_seconds`, and the report adds them to the timing. The kache and mr-boxington actions also install their tool after the timer starts, which took under a second in Zed run 37994555454, about the time of the BoringCache CLI download.

Cold starts with a fresh local workspace. Providers with shared remote caches may still have existing data unless the lane isolates the cache or disables reads. Runner labels also do not guarantee identical CPUs. Each record stores the machine it ran on and the CPU it observed. Remote builder lanes (Depot and Namespace builders) record the builder as their machine; the CPU they observe is the calling runner's, so it is kept as `observed.runner_machine`, and the builder's own hardware is not recorded. Check the lane configuration and recorded machine before interpreting a timing difference.

`base` and `plus` describe declared cache capabilities. They are separate comparisons; a compiler-cache-only lane does not promise the same reuse as a lane that also restores the build directory.

New runs are recorded under `results/`. `data/latest/` contains historical reports from the earlier harness.
