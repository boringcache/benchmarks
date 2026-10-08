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

The generated report excludes failed builds, failed or missing output checks, and warm records without a passing cold record in the same scope. Rows separate source revisions, rolling steps, and BoringCache versions. Inspect the original records as well: performance comparisons require a completed seed and matching source, capability level, runner class, and harness/tool versions. Full harness identity and final post-job save outcomes are not yet captured. Failed attempts remain evidence, and a rerun attempt is recorded next to the first one.

`seconds` measures the timed phase, excluding preparation and output validation. It is not the full job duration. Kache and mr-boxington save in post-job steps after the record is written, so their records carry `cache_save_timing = "post-job"` and their phase times exclude those saves.

Cold starts with a fresh local workspace. Providers with shared remote caches may still have existing data unless the lane isolates the cache or disables reads. Runner labels also do not guarantee identical CPUs. Each record stores the machine it ran on and the CPU it observed; remote builder lanes (Depot and Namespace builders) record the builder as their machine. Check the lane configuration and recorded machine before interpreting a timing difference.

`base` and `plus` describe declared cache capabilities. They are separate comparisons; a compiler-cache-only lane does not promise the same reuse as a lane that also restores the build directory.

New runs are recorded under `results/`. `data/latest/` contains historical reports from the earlier harness.
