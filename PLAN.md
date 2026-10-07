# Benchmarks, product first

A plan to reset this repository to one simple shape: run the BoringCache
product adapters on real projects, run the industry-standard alternative on the
same projects, and report the numbers. Nothing in here is invented for the
benchmark. The product is used exactly as a user would use it.

## Why reset

The current layout grew in five days from an index aggregator into 36 workflows,
17 composite actions, 60 Ruby scripts, 75 case directories, migration state,
suites, series, cohorts, baselines, evidence registries and a cadence monitor.
Rolling never reached a steady cadence because every run depends on state kept
in the repository (series, seeds, queues, recovery runs) and every family has its
own workflow shape. The product config was often hidden behind wrappers, so a
reader could not tell what BoringCache was actually doing.

The fix is not another layer. It is fewer concepts:

| Concept | Meaning | Where it lives |
| --- | --- | --- |
| Family | One BoringCache product adapter (`docker`, `bazel`, `turbo`, ...) | `adapters/<family>/` |
| Case | One pinned open-source project built with that family | `adapters/<family>/cases/<project>/` |
| Lane | One cache provider for that family (`boringcache`, `actions-cache`, `depot`, ...) | `adapters/<family>/lanes/<lane>/` |
| Runner | Compute only. A label, nothing else | `runners.toml` |
| Phase | `cold`, `warm`, `changed`. One timer each | `bin/bench` |
| Result | One JSON record per phase run | `results/` |

Everything else goes.

## Layout

```
benchmarks/
  README.md
  PLAN.md
  bin/bench                      # the only entry point; runs on a laptop or in CI
  runners.toml                   # compute labels, see Runners
  schedule.toml                  # which family/case/lane/runner runs when
  adapters/
    docker/
      README.md                  # one paragraph: what the product does here, link to product docs
      lanes/
        boringcache/lane.toml    # the product. boringcache/one mode=docker, nothing more
        actions-cache/lane.toml  # docker/build-push-action, cache type=gha
        registry/lane.toml       # cache type=registry on GHCR
        depot/lane.toml          # depot/build-push-action
      cases/
        n8n/
          case.toml              # repo, sha, changed sha, command, output check
          .boringcache.toml      # the product plan, verbatim, as a user would write it
          output-check.sh        # optional; default is "command exited 0"
        posthog/
        ...
    docker-tool-cache/           # tool-cache = [...] in the docker adapter, same lanes shape
    docker-mount-cache/          # mount-cache = true, comparator is buildkit-cache-dance
    bazel/
    turbo/
    nx/
    gradle/
    maven/
    go/
    cargo/
    sccache/
    ccache/
    nix/
  results/
    <family>/<case>/<lane>/<runner>/<run-id>.json   # append only
  .github/workflows/
    bench.yml                    # one reusable workflow
    schedule.yml                 # cron, reads schedule.toml, calls bench.yml
    check.yml                    # bin/bench check on pull requests
```

Three folders decide what runs: the family, the case under it, the lane under
it. There is no `cases/` at the root, no `suites/`, no `series`, no
`migration/`, no `schemas/` beyond the two tiny TOML shapes below.

## The three files

`case.toml` describes the project. It must be readable by someone who has never
seen this repository.

```toml
repo = "n8n-io/n8n"
sha = "8f3c2a7e0d6b4c1f9a2e5d8c7b6a5f4e3d2c1b0a"          # cold and warm build this
changed_sha = "a1b2c3d4e5f60718293a4b5c6d7e8f9012345678"  # changed phase builds this
command = "docker buildx build --file docker/images/n8n/Dockerfile --platform linux/amd64 --tag n8n:bench ."
output_check = "docker image inspect n8n:bench"           # optional, default: exit code of command
lanes = ["boringcache", "actions-cache", "depot"]           # subset of the family's lanes
runners = ["github", "depot"]                               # keys from runners.toml
platform = "linux/amd64"
```

`.boringcache.toml` is the product plan. It is copied from the product docs for
that adapter and nothing is added for the benchmark. The `boringcache` lane runs
the case command through it. A reader can paste it into their own repository.

`lane.toml` describes a provider once per family, not per case.

```toml
name = "actions-cache"
description = "docker/build-push-action with cache-from/cache-to type=gha,mode=max"
requires = "github-actions"     # or "any". type=gha only works inside Actions
setup = "setup.sh"              # install or configure the provider; untimed
run = "run.sh"                  # run the case command with this provider's cache; timed
reports_cache = true            # provider prints hit/miss and bytes we can record
```

`run.sh` receives `BENCH_COMMAND`, `BENCH_PHASE`, `BENCH_SCOPE` and the case
directory. It runs the command with the provider's cache attached. For the
`boringcache` lane that is literally `boringcache run` against the case's plan,
or the `boringcache/one` action with `mode=<family>` when on Actions. For
`actions-cache` on Docker it is `docker buildx build --cache-from type=gha
--cache-to type=gha,mode=max`. Nothing in `run.sh` times, reports, or decides
policy. `bin/bench` does that for every lane the same way.

## Phases

Each phase is one workflow step and one timer. No sub-steps, no setup inside the
timer.

| Phase | Source | Cache state before | What the number means |
| --- | --- | --- | --- |
| `cold` | `sha` | empty scope | build with nothing to reuse, and publish the cache |
| `warm` | `sha` | from `cold` | identical source replay |
| `changed` | `changed_sha` | from `warm` | realistic next commit |

All three run in the same job on the same runner label with the same scope, in
that order. The scope is fresh per run (`<family>-<case>-<lane>-<run-id>`), so a
run never depends on a previous run and there is no seed state to keep in git.
A "rolling" series is just running `changed` more than once with more SHAs; add
`changed_shas = [...]` later if we want it. Do not build it now.

What gets recorded per phase:

```json
{
  "family": "docker", "case": "n8n", "lane": "actions-cache", "runner": "github",
  "phase": "warm", "seconds": 212.4, "output_ok": true,
  "cache": { "hit": true, "restored_bytes": 1830000000, "saved_bytes": 0, "source": "provider" },
  "run": { "url": "https://github.com/boringcache/benchmarks/actions/runs/1", "sha": "...", "cli_version": "1.40.0" },
  "started_at": "2026-10-07T10:00:00Z"
}
```

`seconds` is the wall time of the step. `cache` is filled only when the provider
reports it; otherwise it is `null`, which the report shows as unmeasured, never
as zero. `output_ok` is the output check. That is the whole record.

## Lanes per family

The comparator in each family is the thing the family's own docs tell a GitHub
Actions user to do. The `boringcache` lane is the product adapter with the same
name. Nothing else is required to start; add a lane when we want the number.

| Family | `boringcache` lane | Industry-standard lane on Actions | Other lanes worth adding |
| --- | --- | --- | --- |
| docker | `mode=docker` | `docker/build-push-action` cache `type=gha,mode=max` | `type=registry` (GHCR), `depot/build-push-action`, Namespace builders |
| docker-tool-cache | `mode=docker` with `tool-cache = [...]` | `type=gha` plus the tool's own GHA cache inside the build (for example sccache with the GHA backend) | Depot |
| docker-mount-cache | `mode=docker` with `mount-cache = true` | `type=gha` plus `reproducible-containers/buildkit-cache-dance` | Depot, which persists mounts on its builders |
| bazel | `mode=bazel` (remote cache through the proxy) | `bazel-contrib/setup-bazel` disk and repository cache on `actions/cache` | BuildBuddy remote cache, NativeLink, EngFlow |
| turbo | `mode=turbo` | `actions/cache` on `.turbo` as the Turborepo docs show | Vercel Remote Cache, Depot Cache |
| nx | `mode=nx` | `actions/cache` on `.nx/cache` | Nx Cloud, Depot Cache |
| gradle | `mode=gradle` | `gradle/actions/setup-gradle` built-in cache | Develocity build cache, Depot Cache |
| maven | `mode=maven` | `actions/setup-java` with `cache: maven` | Depot Cache |
| go | `mode=go` | `actions/setup-go` with `cache: true` | none needed |
| cargo | `mode=cargo` | `Swatinem/rust-cache` | `mozilla-actions/sccache-action` with the GHA backend, Depot Cache |
| sccache | `mode=sccache` | `mozilla-actions/sccache-action`, GHA backend | Depot Cache |
| ccache | `mode=ccache` | `hendrikmuhs/ccache-action` | none needed |
| nix | `mode=nix` | `cachix/cachix-action` | `DeterminateSystems/magic-nix-cache-action` |

A lane that only works inside Actions says so with `requires =
"github-actions"`. `bin/bench` skips it on a laptop and says why. The
`boringcache` lane works everywhere because the CLI does.

## Runners

Runners are compute, not cache. `runners.toml` is a list of labels:

```toml
[github]    label = "ubuntu-latest"
[github-arm] label = "ubuntu-24.04-arm"
[depot]     label = "depot-ubuntu-22.04"
[namespace] label = "nscloud-ubuntu-22.04-amd64-4x8"
[blacksmith] label = "blacksmith-4vcpu-ubuntu-2204"
[local]     label = "local"
```

A case lists which runner keys it runs on. The lanes do not change with the
runner. Depot builders and Namespace builders are lanes in the Docker family,
not runners, because the cache lives with the builder. A result always carries
both `lane` and `runner`, so "Depot runner with Actions Cache" and "GitHub
runner with Depot builder" stay separate rows.

## One entry point

`bin/bench` is one Ruby file and a small lib. It is the only place that knows
about phases, timers, scopes and result records. The same commands run on a
laptop and inside the workflow.

```sh
bin/bench check                                        # validate every case.toml and lane.toml
bin/bench list                                         # families, cases, lanes, runners
bin/bench prepare docker/n8n                           # clone sha into .work/, untimed
bin/bench run docker/n8n --lane boringcache --phase cold
bin/bench run docker/n8n --lane boringcache --phase warm
bin/bench run docker/n8n --lane boringcache --phase changed
bin/bench report                                       # table from results/, no verdicts
```

`bench.yml` is a thin caller of exactly those commands:

```yaml
jobs:
  bench:
    runs-on: ${{ inputs.runner_label }}
    steps:
      - uses: actions/checkout
      - run: bin/bench prepare ${{ inputs.case }}
      - run: bin/bench lane-setup ${{ inputs.case }} --lane ${{ inputs.lane }}
      - name: cold
        run: bin/bench run ${{ inputs.case }} --lane ${{ inputs.lane }} --phase cold
      - name: warm
        run: bin/bench run ${{ inputs.case }} --lane ${{ inputs.lane }} --phase warm
      - name: changed
        run: bin/bench run ${{ inputs.case }} --lane ${{ inputs.lane }} --phase changed
      - uses: actions/upload-artifact   # results/**.json
```

The `boringcache` lane on Actions uses the public `boringcache/one` action with
`mode=<family>` in `lane-setup`, pinned to one version in `lane.toml`. No wrapper
action, no evidence retention action, no provider selection action.

`schedule.yml` runs on cron, reads `schedule.toml`, and calls `bench.yml` once
per `(case, lane, runner)` row. Results are committed back to `results/` by one
job at the end. That is the whole cadence.

```toml
[[nightly]]
cases = ["docker/n8n", "docker/posthog", "turbo/n8n", "bazel/grpc"]
lanes = ["boringcache", "actions-cache"]
runners = ["github"]

[[weekly]]
cases = ["docker/n8n"]
lanes = ["boringcache", "actions-cache", "depot"]
runners = ["github", "depot", "namespace"]
```

## How we keep it deterministic

- Adding a provider is one directory: `adapters/<family>/lanes/<name>/` with
  `lane.toml`, `setup.sh`, `run.sh`. `bin/bench check` fails if any is missing
  or if `run.sh` does not use `BENCH_COMMAND`.
- Adding a case is one directory with `case.toml` and `.boringcache.toml`.
  `bin/bench check` fails on a short SHA, a missing `changed_sha`, a lane the
  family does not have, or a runner key not in `runners.toml`.
- Adding a family is one directory with a `README.md`, at least the
  `boringcache` lane and one industry-standard lane, and one case.
- Phases, timers, scopes and the result record exist once, in `bin/bench`.
  Lanes and cases cannot add steps.
- The product is never wrapped. `.boringcache.toml` and `mode=<family>` are the
  product surface. If the product needs a flag for a benchmark to work, that is
  a product issue, not a benchmark feature.
- Reports show medians, ranges, sample counts, unmeasured cells and failed runs.
  No verdicts and no explanations in generated output.

## Reset steps

1. Branch from `main`. Do not rewrite history; one commit removes the old layout.
   Tag the last old commit `layout-2026-10-06` so the evidence under `data/`,
   `migration/` and `results/` stays reachable.
2. Delete `cases/`, `suites/`, `schemas/`, `migration/`, `config/`, `data/`,
   `docs/`, `scripts/`, `test/`, `.github/actions/` and all workflows.
3. Salvage only data, not code, from the old cases into new `case.toml` files:
   upstream repo, full SHA, a second SHA, the build command, and the output
   check. The old `.boringcache.toml` payloads mostly carry over as they are.
   Dockerfile overlays under `adapters/docker/overlays/` are patches to upstream
   and are recorded in `case.toml` as `patch = "..."` when we keep one.
4. Write `bin/bench` with `check`, `list`, `prepare`, `lane-setup`, `run`,
   `report`. Ruby, Minitest, one lib directory.
5. Start with the Docker family and one case (`n8n`), two lanes (`boringcache`,
   `actions-cache`), one runner (`github`). Run all three phases locally with the
   `boringcache` lane, then once on Actions with both lanes.
6. Add `turbo/n8n`, `bazel/grpc` and `docker-mount-cache` with the same shape
   before any other family. If the shape needs to change for these, change it
   now, then freeze it.
7. Turn on `schedule.yml` nightly for that set. Only after a week of green nightly
   runs, add runners and the next families.

## What this plan does not do

- No rolling state in git. `changed` gives the changed-source number; longer
  chains are a later `changed_shas` list.
- No evidence registry. The result record carries the run URL, SHA and CLI
  version. The run log is the evidence.
- No cross-case publication pipeline. `bin/bench report` writes one markdown
  table from `results/`. The product site reads `results/` directly.
- No per-case workflows and no per-case actions. One workflow, one entry point.
