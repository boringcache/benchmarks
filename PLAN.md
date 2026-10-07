# Benchmarks rebuild plan (v2)

Status: draft for review. Nothing below is built yet.

`main` was reset on 2026-10-07 to the tree of `c750b51d` (the index before the
consolidation) by a normal commit, `16c684ee`. The consolidated layout stays in
history at `e24f6442`. The 827 workflow runs created by the consolidation are
being deleted; their inventory is kept outside the repo.

Everything in this plan comes from the archived `benchmark-*` repos, the
consolidated repo at `e24f6442`, the BoringCache CLI, and provider docs. Where
something is a new design choice it says so. Open questions are at the end.

## Goals

1. One shape. Grouped by BoringCache tool, then project, then lane.
2. Adding a case or a provider means copying one directory, not editing ten files.
3. The same command runs a case on a laptop and on GitHub Actions.
4. BoringCache is used only through its product commands and `.boringcache.toml`.
5. One BoringCache version pin. Release tooling bumps that one line.
6. Every run emits one result record per phase. Reports are generated from those.

## Layout

```
bin/bench                    # the only entry point (Ruby)
lib/bench/                   # small library behind bin/bench
test/                        # Minitest
versions.toml                # every version pin: boringcache, depot, sccache, ccache, nativelink, ...
runners.toml                 # runner keys -> labels
schedule.toml                # what runs when
tools/
  docker/
    README.md                # what the product does here, link to product docs
    lanes/
      boringcache.rb         # boringcache docker -- <command>              (layers)
      boringcache-plus.rb    # + tool-cache + mount-cache                   (the whole backend)
      gha.rb                 # --cache-from/--cache-to type=gha,mode=max
      depot-builder.rb       # depot build with the same arguments
    posthog/
      case.toml              # source, command, output check, lanes, runners
      .boringcache.toml      # the product plan, as a user would commit it
      overlay/               # only when a lane needs upstream changes (recorded, never hidden)
    n8n/ ...
  turbo/ nx/ bazel/ cargo/ go/ gradle/ maven/ ccache/ xcode/ nix/ moon/ pants/ buck2/ sbt/ run/
results/                     # one JSON record per phase run, append only
data/results.json            # generated report (new format)
data/latest/                 # September index the website reads today; removed when the reader switches
.github/workflows/
  bench.yml                  # one reusable workflow: cold -> warm -> changed for one case/lane/runner
  schedule.yml               # cron; reads schedule.toml; calls bench.yml
  check.yml                  # bin/bench check + tests on pull requests
```

A tool directory exists only when it has a case. `buildkit`, `sccache`, `gha` and
`bazel-reapi` have no case today (sccache is used inside the cargo and docker
cases), so they start without a directory.

Lanes are small Ruby files because each provider attaches differently (flags,
env, init scripts). A lane declares setup (untimed), how it wraps the case
command for each phase, which runner keys it is valid on, which secrets it reads,
and how it shows reuse on warm. Nothing in a lane times, records or decides
policy; `bin/bench` does that for every lane.

Pairs are explicit. A case's `[runs]` table lists the runners for each lane, and
`bin/bench check` rejects a pair the lane does not allow. Example: `gha` is valid
only on `github`, because on Depot runners `type=gha` and `actions/cache` go to
Depot Cache, which is a different provider.

## The case file

```toml
# tools/docker/posthog/case.toml — shape only; real values come from
# e24f6442:cases/posthog (pin 55e3e899…, upstream/Dockerfile, linux/amd64)
repo    = "PostHog/posthog"
sha     = "<40-char sha>"        # cold and warm build this
changed_sha = "<40-char sha>"    # changed phase builds this (see open question 1)
prepare = []                     # untimed, after checkout (e.g. pnpm install)
command = ["docker", "buildx", "build", "--file", "Dockerfile", "--platform", "linux/amd64", "--provenance", "false", "--load", "--tag", "posthog:bench", "."]
check   = ["docker", "image", "inspect", "posthog:bench"]   # runs after the timer

[runs]                           # lane -> runners; exactly these pairs run, nothing else
boringcache      = ["github", "depot-4", "depot-8", "namespace-4", "namespace-8"]
boringcache-plus = ["github", "depot-4", "depot-8", "namespace-4", "namespace-8"]
gha              = ["github"]
depot-builder    = ["github"]

[plus]                           # docker only: what boringcache-plus adds
tool_cache = ["turbo"]
mount_cache = true
dockerfile = "overlay/PostHog.Dockerfile"
```

`.boringcache.toml` is the product plan with `workspace = "boringcache/benchmarks"`.
It is copied from the last consolidated case (`e24f6442:cases/<id>/`), which kept
the archived repo plans unchanged apart from the workspace.

## Phases and timing

| Phase | Source | Cache before | Saves? | Runs on |
| --- | --- | --- | --- | --- |
| `cold` | `sha` | empty scope | yes | fresh runner |
| `warm` | `sha` | what cold saved | no, restore only | fresh runner |
| `changed` | `changed_sha` | what cold saved | yes | fresh runner |

- The save rule is the same for every lane. Warm is restore-only, as in every
  archived repo: BoringCache `--read-only` (or `trust-policy: restore`),
  `actions/cache/restore`, remote caches with uploads off
  (`--remote_upload_local_results=false` and equivalents).
- Warm must show reuse, or it is recorded as a failed run, not a timing. The
  archived repos used `fail-on-cache-miss: true`; each lane states how it shows
  reuse (cache hit output, provider-reported hits, BoringCache evidence).

- Each phase is its own job on Actions, so no local state carries over. This is
  what the archived repos did for fresh runs. Locally, `bin/bench` resets the work
  directory, tool cache directories and the Docker builder between phases.
- The scope is new per run: `<tool>-<case>-<lane>-<runner>-<run-id>`. No seed
  state lives in git.
- The timer covers cache restore, the command, and cache save. For BoringCache
  that is one command. For `actions/cache` lanes, restore and save are separate
  workflow steps, so `bin/bench time start` and `bin/bench time stop` bracket them.
- Untimed: checkout, toolchain install, `prepare`, provider install, output check.
- The output check must pass before a timing counts.

## Result record

One file per phase: `results/<tool>/<case>/<run-id>/<lane>-<runner>-<phase>.json`.

```json
{
  "tool": "docker", "case": "posthog", "lane": "boringcache", "runner": "github",
  "runner_label": "ubuntu-latest", "phase": "warm", "sha": "...",
  "seconds": 212.4, "exit_status": 0, "output_ok": true,
  "cache": { "source": "boringcache", "hits": null, "misses": null, "restored_bytes": null, "saved_bytes": null },
  "storage_bytes": null,
  "versions": { "boringcache": "1.40.0" },
  "run_url": "https://github.com/boringcache/benchmarks/actions/runs/...", "attempt": 1,
  "started_at": "2026-10-07T10:00:00Z"
}
```

Values a provider does not report stay `null` and show as unmeasured, never zero.
Local runs record `runner = "local"` and are for verification, not published
comparisons.

## Same command locally and on Actions

```sh
bin/bench check                                   # validate every case, lane, runner, pin
bin/bench list                                    # tools, cases, lanes, runners
bin/bench run docker/posthog --lane boringcache   # cold, warm, changed locally
bin/bench run docker/posthog --lane boringcache --phase warm   # one phase (what Actions calls)
bin/bench report                                  # results/ -> data/results.json
```

- BoringCache on a laptop uses the developer's login. On Actions the step runs
  under `boringcache ci run --oidc-provider github-actions -- bin/bench ...`, the
  CLI's own OIDC path. The consolidated REAPI harness already ran this way. The
  CLI is installed from the GitHub release named in `versions.toml`.
- Lanes that need Actions (`gha`, and anything on Depot or Namespace runners) are
  skipped locally with the reason printed.
- `bench.yml` is the only workflow that pins third-party actions.

## Lanes per tool

The BoringCache lane is the product command for that tool. The other lanes are
the providers you named, limited to the tools their docs support.

| Tool | Cases | BoringCache | Other lanes (from you + provider docs) |
| --- | --- | --- | --- |
| docker | posthog, n8n, n8n-runners, n8n-runners-distroless, immich, immich-base-images, mastodon, mastodon-streaming, hugo, duckgres, chroma, linkerd2, qdrant, discourse? | `boringcache`, `boringcache-plus` | `gha` (type=gha), `depot-builder` |
| turbo | n8n | `boringcache turbo` | `gha` (actions/cache on .turbo), `depot-cache`, Cachely?, Vercel? |
| nx | storybook | `boringcache nx` | `gha`, `depot-cache`, Cachely?, Nx Cloud (needs a workspace) |
| run | storybook (archive sandbox, the original benchmark) | `boringcache run` | `gha` |
| bazel | grpc | `boringcache bazel` | `gha` (disk cache), `buildbuddy`, `cachely`, `nativelink` (R2), `depot-cache` |
| cargo | deno, zed | `boringcache cargo` (sccache compiler cache, as committed) | `gha` (see question 5), `depot-cache` (sccache WebDAV) |
| go | hugo | `boringcache go` | `gha`, `depot-cache` |
| gradle | opentelemetry-java | `boringcache gradle` | `gha`, `depot-cache`, Cachely?, Bitrise? |
| maven | spring-ai | `boringcache maven` | `gha`, `depot-cache` |
| ccache | obs-studio (Linux) | `boringcache ccache` | `gha` |
| xcode | obs-studio (macOS) | `boringcache xcode` | `gha`, `bitrise` |
| nix | helix, zed | `boringcache nix` | `cachix`, magic-nix-cache? |
| moon | gogs, opencut, zitadel | `boringcache moon` | `depot-cache`, see question 6 |
| pants | stackstorm, pants-jvm | `boringcache pants` | `depot-cache`, `nativelink`, see question 6 |
| buck2 | executorch, buck2-prelude | `boringcache buck2` | `nativelink`, see question 6 |
| sbt | msgpack-java | `boringcache sbt` | see question 6 |

`?` marks a provider whose docs support the tool but which you have not
confirmed for it.

### Docker `boringcache-plus`

Tool cache plus mount cache, using only overlays that already exist:

| Case | Tool cache | Mount cache | Overlay source |
| --- | --- | --- | --- |
| posthog | turbo | yes | archived `render-posthog-toolcache-dockerfile.sh` |
| chroma | sccache | cargo target, registry, git | archived `docker/chroma.Dockerfile` |
| mastodon | ccache (libvips, ffmpeg) | apt cache mounts | consolidated `server-ccache` Dockerfile (ccache 4.13.6) |
| immich-base-images | ccache (libvips) | to check | archived `prepare-immich-base-images-source.py` |

Other Docker cases get `boringcache-plus` only if their upstream Dockerfile has
`RUN --mount=type=cache` steps; that is checked when each case is ported.

## Runners

```toml
# runners.toml
github      = "ubuntu-latest"
github-arm  = "ubuntu-24.04-arm"
macos       = "macos-26"
depot-4     = "depot-ubuntu-24.04-4"         # 4 vCPU / 16 GB
depot-8     = "depot-ubuntu-24.04-8"         # 8 vCPU / 32 GB
namespace-4 = "namespace-profile-buildkit-4c" # 4 vCPU / 16 GB, Docker "No caching", no volumes
namespace-8 = "namespace-profile-buildkit-8c" # 8 vCPU / 16 GB, Docker "No caching", no volumes
local       = "local"
```

- PostHog runner comparison: `boringcache` and `boringcache-plus` on `github`,
  `depot-4/8`, `namespace-4/8`, against `depot-builder` (Depot's own builder) and
  `gha` on `github`.
- Zed runs its cargo lanes on `namespace-8` with no Namespace cache, as upstream
  runs on Namespace. Upstream uses profiles up to 16x32; the largest profile in
  this workspace is 8x16.
- Namespace is on a trial with 23 days left as of 2026-10-07. Bitrise Build Cache
  is a 30-day trial; what happens after it is not documented.
- Cachely's free plan caps storage at 1 GiB and stops writes at the cap. The
  "benchmark" workspace already shows about 889 MB uploaded in the last month,
  so the Bazel Cachely lane may hit the cap unless the workspace is on a paid plan.
- Depot runners route `actions/cache` and every supported tool to Depot Cache
  automatically (org setting). That matters for any non-Docker lane on a Depot
  runner (question 4).

## Version pins

`versions.toml` holds every pin: the BoringCache CLI, and the versions of
competitor binaries (depot CLI, sccache, ccache, NativeLink, Nix, cachix).
Release tooling (`monorepo/bin/sync-benchmark-pins`) changes to: write
`boringcache = "x.y.z"` in `versions.toml`, run `bin/bench check`, commit. The
monorepo change and its proof come after the Docker family runs here.

## Reports and the website

`bin/bench report` writes `data/results.json` and `data/report.md` from
`results/`: measurements, units, sample counts, unmeasured cells, failed runs,
run links. No verdicts.

The website reads `main/data/latest/index.json`, which now holds the September
data again. The new report goes to a new path so that file is never overwritten
by accident. When the web reader
(`web/app/models/reporting/benchmark_comparisons.rb`) switches to
`data/results.json`, the old `data/latest/` directory and its scripts are removed
in one commit.

## Build order

1. `bin/bench` (check, list, run, time, report), `versions.toml`, `runners.toml`,
   tests. No cases yet.
2. `docker/posthog` with `boringcache` and `boringcache-plus`. Run all three
   phases locally. Then `bench.yml` on `github` with all four Docker lanes.
3. PostHog runner comparison on Depot and Namespace runners.
4. The remaining Docker cases, one at a time, each verified locally first.
5. One case per remaining tool in this order: turbo/n8n, bazel/grpc, cargo/zed
   (Namespace), nx/storybook, go, gradle, maven, ccache, xcode, nix, moon, pants,
   buck2, sbt. Then the remaining cases.
6. `schedule.yml` once a tool's cases pass on Actions.
7. Monorepo follow-ups: release pin tooling, website reader.

Each step is checked locally first, then on Actions, before it is pushed to
`main`.

## Open questions (each has a default; say only where you disagree)

1. **Changed phase source.** Deno, Zed and OBS already have base/head pairs.
   Default for the rest: `sha` = the pin's first parent, `changed_sha` = the pin.
   That is one real upstream commit.
2. **Rolling.** The archived repos also ran a rolling chain per upstream commit.
   Default: leave it out until cold/warm/changed runs steadily.
3. **BoringCache on Actions.** Default: the CLI under `boringcache ci run`, so
   laptop and Actions run the same command with one version pin. The alternative
   is the `boringcache/one` action, which the archived repos used.
4. **Depot Cache lanes.** Default: configure Depot Cache by hand (`cache.depot.dev`
   with `DEPOT_TOKEN`) on the same `github` runner as the other lanes, so the
   runner class matches. Depot runners are used only for the PostHog runner
   comparison.
5. **Cargo `gha` lane.** Default: keep the archived Zed lane (`actions/cache` on
   cargo registry, git and a local sccache directory). `Swatinem/rust-cache` was
   never used here.
6. **Moon, Pants, Buck2, sbt comparators.** The consolidation used a local
   `bazel-remote` server. Default: NativeLink for Buck2 and Pants, Depot Cache for
   Moon and Pants (both documented), and drop `bazel-remote`. sbt has no
   documented provider, so it starts as BoringCache only. Do you want a comparator
   for sbt?
7. **Extra providers the docs support.** Default: add Magic Nix Cache for Nix. It
   needs no credentials and works again since June 2025 (v15, September 2026).
   Hold these until you ask:
   - Cachely for Gradle, Nx and Turbo
   - Bitrise for Gradle and Bazel
   - Vercel Remote Cache for Turbo (free, OIDC)
8. **Cases.** Default: bring Discourse back from the `boringcache/discourse_docker`
   fork and include `run/storybook` (the original archive-mode benchmark). Add
   buck2-prelude, pants-jvm and zitadel-moon, which never ran, last.
9. **Publishing results.** Default: one job opens a pull request with the new
   records after a scheduled run, so publication is a reviewed step.
10. **Lane names.** Default: `boringcache` and `boringcache-plus` for your
    "docker" and "docker+".
11. **Cachely plan.** Is the "benchmark" workspace on a paid plan? If not, the
    Bazel lane may hit the 1 GiB storage cap.
