# Benchmarks rebuild plan (v3)

Status: agreed shape, a few items open (end of file). Nothing is built yet.

`main` was reset on 2026-10-07 to the tree of `c750b51d` (2026-09-30, the index
before the consolidation) by a normal commit, `16c684ee`. The consolidated layout
stays in history at `e24f6442`. The 827 workflow runs it created were deleted;
their inventory is kept outside the repo.

Facts here come from the archived `benchmark-*` repos, the consolidated repo at
`e24f6442`, the BoringCache CLI and `boringcache/one`, and provider docs.

## Goal

A benchmark that is easy to configure and easy to extend. Every lane uses each
product the way its docs tell a user to: BoringCache through its CLI and Action
with a committed `.boringcache.toml`, competitors through their documented setup.
The harness around them stays thin. Each run produces numbers for build time,
cache restore and save, storage, and any latency the product reports. Adding a
case or a provider follows the same steps every time and yields the same record.

## Layout

```
bin/bench                    # the only entry point (Ruby)
lib/bench/                   # small library behind bin/bench
test/                        # Minitest
versions.toml                # version pins: boringcache, depot, sccache, ccache, nativelink, nix, ...
runners.toml                 # runner keys -> labels
schedule.toml                # what runs when
tools/
  docker/
    README.md                # what the product does here, link to product docs
    lanes/                   # one small Ruby file per lane
      boringcache-docker.rb
      boringcache-docker-plus.rb
      gha.rb
      depot-builder.rb
    posthog/
      case.toml              # source, prepare, output check, lane -> runners
      .boringcache.toml      # plan for boringcache-docker; its [adapters.docker].command IS the build command
      plus/.boringcache.toml # plan for boringcache-docker-plus: + tool-cache, mount-cache
      overlay/               # upstream changes a lane needs, recorded, never hidden
      upstream/              # source checkout (gitignored)
  turbo/ nx/ run/ bazel/ cargo/ go/ gradle/ maven/ ccache/ xcode/ nix/ moon/ pants/ buck2/ sbt/
results/                     # one JSON record per phase run (also the rolling cursor)
data/results.json            # generated report, new format
data/latest/                 # September index the website reads today; removed when the reader switches
.github/workflows/
  bench.yml                  # reusable: one case, lane, runner, phase
  schedule.yml               # cron; reads schedule.toml; calls bench.yml; commits results
  check.yml                  # bin/bench check + tests on pull requests
```

A tool directory exists only when it has a case. `buildkit`, `sccache`, `gha` and
`bazel-reapi` have none yet (sccache is used inside the cargo and docker cases).

## One command, one plan

The build command lives once, in the case's `.boringcache.toml`
(`[adapters.<tool>].command`), next to an `upstream/` checkout, the same layout
the archived repos used.

- **BoringCache on a laptop:** `bin/bench` runs `boringcache <tool>` in the case
  directory. The CLI finds the plan by walking up from the working directory.
- **BoringCache on Actions:** `bench.yml` uses `boringcache/one` with
  `mode: <tool>` and `working-directory: tools/<tool>/<case>`. The Action runs
  the committed command, as its README describes. `boringcache-docker-plus`
  points `working-directory` at `plus/`.
- **Every other lane** reads the same command from that plan and attaches its own
  cache (flags, env, init script), so all lanes build exactly the same thing.

`case.toml` holds only what the plan does not:

```toml
# tools/docker/posthog/case.toml — shape only; values come from e24f6442:cases/posthog
repo      = "PostHog/posthog"
branch    = "master"
start_sha = "<first-parent commit on master at 2026-09-30 23:59 UTC>"
prepare   = []                                        # untimed, after checkout
check     = ["docker", "image", "inspect", "posthog:bench"]   # after the timer

[runs]                                                # lane -> runners; only these pairs run
boringcache-docker      = ["github", "depot-4", "depot-8", "namespace-4", "namespace-8"]
boringcache-docker-plus = ["github", "depot-4", "depot-8", "namespace-4", "namespace-8"]
gha                     = ["github"]
depot-builder           = ["github"]
```

A lane declares setup (untimed), how it wraps the command, which runner keys it
is valid on, its secrets, and how it shows reuse. `bin/bench check` rejects a
pair the lane does not allow (for example `gha` on a Depot runner, where
`type=gha` and `actions/cache` go to Depot Cache instead).

## Phases

**Fresh** (repeatable samples at a fixed source):

| Phase | Source | Cache before | Saves |
| --- | --- | --- | --- |
| `cold` | `start_sha` | empty, new scope | yes |
| `warm` | `start_sha` | what cold saved | no, restore only |

**Rolling** (a chain through real upstream history, starting at the reset date):

- The series starts with a cold seed at `start_sha`, the upstream first-parent
  commit as of 2026-09-30.
- Each tick builds the next first-parent commit after the last recorded one,
  restoring and saving the series scope. Every lane of a case builds the same
  commit in the same tick.
- The cursor is the last rolling record in `results/`, so no separate state file
  exists. The commit list comes from `git rev-list --first-parent` on upstream.
- The scope is fixed per series: `<tool>-<case>-<lane>-<runner>-rolling-<series>`.

**Rules for every lane:**
- Each phase runs on a fresh runner (its own job on Actions). Locally, `bin/bench`
  resets the work directory, tool caches and the Docker builder between phases.
- Warm only restores: BoringCache read-only, `actions/cache/restore`, remote
  caches with uploads off. Warm must show reuse, or it is a failed run, not a
  timing (the archived repos used `fail-on-cache-miss: true`).
- The timer covers restore, the command and save. On Actions, `bin/bench time
  start` and `bin/bench time stop` bracket the Action or cache steps.
  Checkout, toolchain install, `prepare` and the output check are untimed.
- A timing counts only after the output check passes.

## Result record

`results/<tool>/<case>/<series-or-run>/<lane>-<runner>-<phase>[-<n>].json`

```json
{
  "tool": "docker", "case": "posthog", "lane": "boringcache-docker", "runner": "github",
  "runner_label": "ubuntu-latest", "phase": "rolling", "step": 12, "sha": "...",
  "seconds": 212.4, "exit_status": 0, "output_ok": true, "reused": true,
  "cache": { "source": "boringcache", "restore_seconds": null, "save_seconds": null,
             "hits": null, "misses": null, "restored_bytes": null, "saved_bytes": null },
  "storage_bytes": null,
  "versions": { "boringcache": "1.40.0" },
  "run_url": "https://github.com/boringcache/benchmarks/actions/runs/...", "attempt": 1,
  "started_at": "2026-10-07T10:00:00Z"
}
```

Values a provider does not report stay `null` and show as unmeasured, never zero.
Local runs record `runner = "local"`; they verify cases and are not published.

## Commands

```sh
bin/bench check                                            # validate cases, lanes, runners, pins
bin/bench list                                             # tools, cases, lanes, runners
bin/bench run docker/posthog --lane boringcache-docker     # fresh cold + warm locally
bin/bench run docker/posthog --lane boringcache-docker --phase rolling   # next rolling step
bin/bench report                                           # results/ -> data/results.json
```

Lanes that only work on Actions (`gha`, `depot-builder`, Depot/Namespace runners)
are skipped locally with the reason printed.

## Lanes per tool

BoringCache lanes are named `boringcache-<tool>`; Docker also has
`boringcache-docker-plus` (layers + tool cache + mount cache, the whole backend).

| Tool | Cases | Other lanes |
| --- | --- | --- |
| docker | posthog, n8n, n8n-runners, n8n-runners-distroless, immich, immich-base-images, mastodon, mastodon-streaming, hugo, duckgres, chroma, linkerd2, qdrant, discourse | `gha` (type=gha, mode=max), `depot-builder` |
| turbo | n8n | `gha` (actions/cache on .turbo), `depot-cache`, `vercel` |
| nx | storybook | `gha`, `depot-cache`, `nx-cloud` (when a workspace exists) |
| run | storybook (archive sandbox, the original benchmark) | `gha` |
| bazel | grpc | `gha` (disk cache), `buildbuddy`, `cachely`, `nativelink` (R2), `depot-cache` |
| cargo | deno, zed | `gha`: sccache with its GitHub Actions cache backend + `Swatinem/rust-cache` for target and registry; `depot-cache` (sccache WebDAV) |
| go | hugo | `gha`, `depot-cache` |
| gradle | opentelemetry-java | `gha`, `depot-cache` |
| maven | spring-ai | `gha`, `depot-cache` |
| ccache | obs-studio (Linux) | `gha` |
| xcode | obs-studio (macOS) | `gha`, `bitrise` |
| nix | helix, zed | `cachix`, `magic-nix-cache` |
| moon | gogs, opencut | `depot-cache` |
| pants | stackstorm | `depot-cache`, `nativelink` |
| buck2 | executorch | `nativelink` |
| sbt | msgpack-java | `gha` (`actions/setup-java` with `cache: sbt`) |

- Depot Cache is configured by hand on the `github` runner with `DEPOT_TOKEN`
  (`cache.depot.dev`, per Depot's docs for each tool), so every lane shares the
  runner class.
- The local `bazel-remote` comparator from the consolidation is dropped.
- Never-run cases (buck2-prelude, pants-jvm, zitadel-moon) come after everything
  above works.
- Discourse uses the upstream `discourse/discourse` and `discourse/discourse_docker`
  repos, as the archived repo did, not the fork.

### `boringcache-docker-plus`, from overlays that already exist

| Case | Tool cache | Mount cache | Overlay source |
| --- | --- | --- | --- |
| posthog | turbo | yes | archived `render-posthog-toolcache-dockerfile.sh` |
| chroma | sccache | cargo target, registry, git | archived `docker/chroma.Dockerfile` |
| mastodon | ccache (libvips, ffmpeg) | apt cache mounts | consolidated `server-ccache` Dockerfile (ccache 4.13.6) |
| immich-base-images | ccache (libvips) | to check | archived `prepare-immich-base-images-source.py` |

Other Docker cases get the plus lane only if the upstream Dockerfile already has
`RUN --mount=type=cache` steps; that is checked when each case is ported.

## Runners

```toml
# runners.toml
github      = "ubuntu-latest"
github-arm  = "ubuntu-24.04-arm"
macos       = "macos-26"
depot-4     = "depot-ubuntu-24.04-4"          # 4 vCPU / 16 GB
depot-8     = "depot-ubuntu-24.04-8"          # 8 vCPU / 32 GB
namespace-4 = "namespace-profile-buildkit-4c" # 4 vCPU / 16 GB, Docker "No caching", no volumes
namespace-8 = "namespace-profile-buildkit-8c" # 8 vCPU / 16 GB, Docker "No caching", no volumes
local       = "local"
```

- PostHog runner comparison: both BoringCache Docker lanes on `github`,
  `depot-4/8` and `namespace-4/8`, against `depot-builder` and `gha` on `github`.
- Zed runs its cargo lanes on `namespace-8` without any Namespace cache, since
  upstream runs on Namespace. Upstream uses profiles up to 16x32; the largest
  profile in this workspace is 8x16.

## Things to watch

- Namespace is a trial (23 days left on 2026-10-07). Bitrise Build Cache is a
  30-day trial with no documented after-state.
- Cachely's free plan caps storage at 1 GiB; the "benchmark" workspace showed
  about 889 MB uploaded in the last month. It worked before, so we keep it and
  watch for write failures.
- The GitHub Actions cache has a per-repository size limit (10 GB unless raised).
  Many `gha` lanes in one repo compete for it, and evictions would show up as
  warm misses.
- Depot runners auto-connect every supported tool to Depot Cache (org setting),
  which is why non-Docker lanes do not run on Depot runners.

## Version pins

`versions.toml` holds every pin. `bench.yml` pins `boringcache/one@<sha> # vX.Y.Z`
once and passes `cli-version` from `versions.toml`, so laptop and Actions use the
same CLI. Release tooling (`monorepo/bin/sync-benchmark-pins`) is changed later
to update those two lines and run `bin/bench check`.

## Reports and the website

`bin/bench report` writes `data/results.json` and `data/report.md` from
`results/`: measurements, units, sample counts, unmeasured cells, failed runs,
run links. No verdicts. The website keeps reading the September
`data/latest/index.json` until its reader
(`web/app/models/reporting/benchmark_comparisons.rb`) switches to the new file;
then `data/latest/` and its old scripts go in one commit.

## Build order

1. `bin/bench` (check, list, run, time, report), `versions.toml`, `runners.toml`,
   tests. No cases.
2. `docker/posthog`: both BoringCache lanes locally (fresh cold + warm, then two
   rolling steps). Then `bench.yml` on `github` with all four Docker lanes.
3. PostHog runner comparison on Depot and Namespace runners.
4. The other Docker cases, one at a time, each verified locally first.
5. One case per remaining tool: turbo/n8n, bazel/grpc, cargo/zed (Namespace),
   nx/storybook, go, gradle, maven, ccache, xcode, nix, moon, pants, buck2, sbt.
   Then the rest of the cases.
6. `schedule.yml` for each tool once its cases pass on Actions.
7. Monorepo follow-ups: release pin tooling, website reader.

Each step is checked locally first, then on Actions, before it lands on `main`.

## Open items

1. **"cas backend"** in your last message: what should that change?
2. **Results commit.** Rolling reads its cursor from `results/`, so each scheduled
   tick ends with one job committing that tick's records to `main` (not a pull
   request, which would stall the chain). OK?
3. **Vercel credentials** for the `vercel` lane: either an OIDC policy (team
   Settings, OIDC Policies for CLI Access) plus a `TURBO_TEAM` variable, or a
   `TURBO_TOKEN` secret plus a `TURBO_TEAM` variable. Neither exists on the repo yet.
4. **Nx Cloud** needs a workspace before its lane can run.
