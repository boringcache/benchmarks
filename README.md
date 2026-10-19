# BoringCache benchmarks

Build real projects with BoringCache and other cache providers. Each result identifies the source revision, provider, runner, machine, phase, and GitHub Actions run.

[Results](data/report.md) · [JSON](data/results.json) · [Actions](https://github.com/boringcache/benchmarks/actions) · [Configuration](tools/README.md)

## Schedule

The rolling schedule checks the projects in `rolling.toml` every 15 minutes. It dispatches an idle project when its upstream branch has advanced by the case's `rolling_stride` (one commit by default). Running or queued projects wait for a later tick. Each tick's Actions summary lists dispatched, active, current, and failed checks.

Every lane of a case builds the same first-parent commit. Step 0 builds `start_sha` with empty rolling caches. Later steps restore and save each lane's fixed cache scope. Recorded build failures advance the series; setup failures without records do not. Fresh runs use separate caches.

The report updates hourly. Stale BuildKit cache cleanup runs every two hours; ordinary Actions caches are pruned after rolling results are published. GitHub may delay scheduled runs.

## Run

Use the Ruby version in `.tool-versions`:

```sh
bundle install
bundle exec bin/bench check
bundle exec bin/bench matrix grpc --tool bazel
gh workflow run project.yml --ref main -f tool=Bazel -f project=grpc -f mode=fresh
```

- `fresh`: cold and warm builds of `start_sha` on separate runners.
- `rolling`: the next upstream commit due at the configured stride.
- `preflight`: setup and the lane's declared probes, without a build.

Add `-f lane=<lane>` to select lanes or `-f cli=vcli-canary-<sha>` to test a published CLI canary in fresh mode. Canary runs are manual. A cold phase cannot be retried under the same run ID; dispatch another fresh run.

Rolling dispatches use the tool's display title, such as `Rust/Cargo`, so scheduled and manual runs share a concurrency group.

Preview the rolling scheduler without starting builds:

```sh
gh workflow run schedule.yml --ref main -f dry_run=true
```

For local builds and report generation:

```sh
bundle exec bin/bench run bazel/grpc --lane boringcache-bazel
bundle exec bin/bench report --results results --out tmp/report
```

Local builds need the lane's tools and credentials. See [configuration](tools/README.md) for container runs and [AGENTS.md](AGENTS.md) for validation commands.

## Results

`results/` contains measurements and provider evidence. `data/report.md` and `data/results.json` report the current lanes and runners, excluding experimental lanes. Times cover cache restore, build, and cache save; checkout, preparation, and output checks are excluded. [Measurement details](docs/results.md) describe matching, failures, cache misses, and post-job saves.

`data/latest/` contains historical measurements. [PLAN.md](PLAN.md) records removed lanes and restarted series.
