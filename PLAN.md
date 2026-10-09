# Benchmarks rebuild plan (v5)

Status: agreed. Build starts with step 1.

`main` was reset on 2026-10-07 to the tree of `c750b51d` (2026-09-30, the index
before the consolidation) by a normal commit, `16c684ee`. The consolidated layout
stays in history at `e24f6442`. The 827 workflow runs it created were deleted;
their inventory is kept outside the repo.

Facts here come from the archived `benchmark-*` repos, the consolidated repo at
`e24f6442`, BoringCache CLI 1.40.0 source, `boringcache/one` v1.40.0, the
monorepo product contract (`config/benchmark-product-contract.yml`), and provider
docs.

## Goal

A benchmark that is easy to configure and easy to extend. Every lane uses each
product the way its docs tell a user to: BoringCache through its CLI and Action
with a committed `.boringcache.toml`, competitors through their documented setup.
The harness stays thin. Each run produces build time, cache restore and save,
storage, and whatever latency each product reports. Adding a case or a provider
follows the same steps and yields the same record.

## Model: tool → capabilities → lanes → projects

Like code modules. A **tool** is a BoringCache adapter. It has a **base**
capability and may have optional capabilities. A **level** is a named set of
capabilities. A **lane** is one provider implementing one level. A **project**
(case) picks the lanes that apply to it.

Capabilities below are from CLI 1.40.0 (`project_config/model.rs`,
`commands/adapters/command/*`).

| Tool | `base` level | `plus` level adds | Shared layers every lane caches |
| --- | --- | --- | --- |
| docker | BuildKit OCI layer cache (`cache-mode = max`) | `tool-cache` for the tool used inside the Dockerfile, `mount-cache` for `RUN --mount=type=cache` | none (dependencies live inside the image build) |
| cargo | compiler cache: sccache, with a profile of `entries = []` (deno's existing `compiler-only` profile; the CLI default would add registry entries) | registry entries (`cargo-registry-cache`, `cargo-registry-index`, `cargo-git-db`) + `cargo-target` (deno's `cargo-product` profile) | none (registry is part of `plus`) |
| bazel | HTTP remote cache (`/ac`, `/cas`) | — | per case (e.g. Bazel repository cache), set when ported |
| go | `GOCACHEPROG` build cache | — | Go module cache |
| gradle | HTTP build cache (init script) | — | Gradle dependency cache |
| maven | Build Cache Extension remote | — | `~/.m2/repository` |
| turbo | Turborepo remote cache | — | package-manager store (e.g. pnpm store) |
| nx | Nx self-hosted remote cache | — | package-manager store (e.g. yarn cache) |
| ccache | ccache remote storage | — | none |
| xcode | compilation cache (macOS) | — | none |
| nix | binary cache | — | none |
| moon, pants, buck2, sbt | REAPI cache (loopback gRPC) | — | per case, set when ported |
| run | archive of declared entries (no case: `run/storybook` was dropped on 2026-10-07) | — | the entries are the cache |

`buildkit`, `sccache`, `gha` and `bazel-reapi` exist in the CLI but have no case
yet, so they get no directory until one does.

### Lane names

- BoringCache: `boringcache-<tool>` for `base`, `boringcache-<tool>-plus` for
  `plus` (today: `boringcache-docker-plus`, `boringcache-cargo-plus`).
- Others: `<provider>` for `base`, `<provider>-plus` where the provider can do
  `plus` (e.g. cargo `gha-plus` = sccache GitHub Actions backend +
  `Swatinem/rust-cache` for registry and target).
- Every record carries the lane's level and capability list, and the report
  groups lanes by level, so readers always see what is being compared.

### Fairness rules

1. Lanes compared with each other implement the same level.
2. Shared layers are cached by every lane. BoringCache caches them in the same
   plan and the same product step: `[adapters.<tool>].profiles = ["deps"]`
   (`boringcache turbo --dry-run --json` shows the adapter restoring and saving
   those archive entries itself). GitHub Actions cache lanes and remote-only
   providers (Depot Cache, Vercel, BuildBuddy, NativeLink) cache them
   with `actions/cache/restore` and `actions/cache/save` as normal steps inside
   the timer, as their users would on GitHub runners.
3. The timer covers the same window for every lane: restore every cached layer,
   install dependencies, build, save. When a case puts install in the window, the
   committed command does install then build. Checkout, `prepare` (submodules,
   toolchain) and the output check are outside it.
4. Same source, command, runner class, architecture and toolchain for every lane
   of a case. Runner comparisons are their own explicit series.
5. Some comparisons are knowingly not like-for-like (Docker `plus` against the
   Docker `base` lanes, 4-core against 8-core runners). They are run on purpose
   to see how things behave, and every number carries its lane, capabilities and
   runner so a reader knows what it is.

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
    tool.toml                # levels and shared layers for this tool
    lanes/                   # one small TOML file per lane
      boringcache-docker.toml
      boringcache-docker-plus.toml
      gha.toml
      depot-builder.toml
    posthog/
      case.toml              # source, check, lane -> runners
      .boringcache.toml      # base plan; [adapters.docker].command IS the build command
      plus/.boringcache.toml # plus plan: + tool-cache, mount-cache, overlay Dockerfile
      overlay/               # upstream changes a lane needs, recorded, never hidden
  cargo/ turbo/ nx/ run/ bazel/ go/ gradle/ maven/ ccache/ xcode/ nix/ moon/ pants/ buck2/ sbt/
results/                     # one JSON record per phase run (also the rolling cursor)
data/results.json            # generated report, new format
data/latest/                 # September index the website reads today; removed when the reader switches
.github/workflows/
  bench.yml                  # reusable: one case, lane, runner, phase
  schedule.yml               # cron; reads schedule.toml; calls bench.yml; commits results
  check.yml                  # bin/bench check + tests on pull requests
```

## One command, one plan

The build command lives once, in the case's `.boringcache.toml`
(`[adapters.<tool>].command`), next to an `upstream/` checkout, as in the
archived repos.

- **Laptop:** `bin/bench` runs `boringcache <tool>` in the case directory (the
  CLI finds the plan by walking up from the working directory).
- **Actions:** `bench.yml` uses `boringcache/one` (v1.40.0 lists every mode,
  including bazel-reapi, moon, pants, buck2, sbt) with `mode: <tool>` and
  `working-directory: tools/<tool>/<case>` (or `.../plus` for a `plus` lane).
- **Other lanes** run the committed `[adapters.<tool>].command` from the same plan
  file, then attach their own cache (flags, env, init script). Every lane builds
  the same thing. (The dry-run `command` is not used: for Docker it already
  carries BoringCache's injected `--cache-from/--cache-to type=boringcache`.)
- The `plus/` plan is the same command with `../upstream` paths plus the extra
  capabilities.

```toml
# tools/docker/posthog/case.toml — shape only; values come from e24f6442:cases/posthog
repo      = "PostHog/posthog"
branch    = "master"
start_sha = "<latest first-parent commit on master when the case is added>"
prepare   = []                                        # untimed: submodules, toolchain
check     = ["docker", "image", "inspect", "posthog:bench"]   # after the timer

[runs]                                                # lane -> runners; only these pairs run
boringcache-docker      = ["github", "depot-4", "depot-8", "namespace-4", "namespace-8"]
boringcache-docker-plus = ["github", "depot-4", "depot-8", "namespace-4", "namespace-8"]
gha                     = ["github"]
depot-builder           = ["github"]
```

A lane file declares its level, setup (untimed), how it wraps the command, the
runner keys it allows, and its secrets. `bin/bench check`
rejects a pair a lane does not allow and a case that leaves a shared layer out
of any lane.

Implementation: Ruby 4.0.7 (`.tool-versions`), `toml-rb` for our own TOML files
(the consolidation used it), Minitest.

## Phases

**Fresh** (repeatable samples at a fixed source):

| Phase | Source | Cache before | Saves |
| --- | --- | --- | --- |
| `cold` | `start_sha` | empty, new scope | yes |
| `warm` | `start_sha` | what cold saved | no, restore only |

**Rolling** (through real upstream history, starting at each case's `start_sha`):

- Step 0 at `start_sha`, the commit the case starts from, on the lane's fixed rolling cache (`<lane>-<runner>-rolling`), separate from fresh runs.
- Each tick builds the next first-parent commit after the last recorded one,
  restoring and saving the series scope. Every lane of a case builds the same
  commit in the same tick.
- The cursor is the last rolling record in `results/`; there is no other state.
- The scope is fixed per series: `<tool>-<case>-<lane>-<runner>-rolling-<series>`.
- `schedule.yml` uses one `concurrency` group per case series, so two ticks can
  never read the same cursor and build the same commit.

**Every phase:** its own fresh runner on Actions; locally `bin/bench` resets the
work directory, tool caches and Docker builder between phases. Warm only
restores (BoringCache read-only, `actions/cache/restore`, remote uploads off).

**Numbers only.** The record holds what ran and what was measured: time, exit
status, output check, and whatever numbers each product reports itself, copied
as reported. The harness does not judge whether a cache was reused or whether a
result is good. What it guarantees is honest wiring: the same command for every
lane, and each product's cache set up the way that product documents it.

## Results

1. Each phase writes one record:
   `results/<tool>/<case>/<series-or-run>/<lane>-<runner>-<phase>[-<step>].json`.
2. On Actions each job uploads its record and the raw product evidence (the
   Action's `evidence-path` file, the CLI session JSONL) as an artifact. At the
   end of a tick one job downloads them, commits the records to `main` in one
   commit, and regenerates `data/results.json` and `data/report.md`.
3. Rolling reads the last committed record to find the next upstream commit.
4. Local runs write the same records to a gitignored directory; they verify a
   case and are never published.
5. Failed runs are recorded and kept. Missing values are `null` (unmeasured).
6. Field names follow the product vocabulary: the command name goes in
   `adapter_command` (`docker`, `turbo`, `go`); any `tool` field would have to use
   the canonical names (`oci`, `turborepo`, `gocache`, …), so the record has none.

```json
{
  "adapter_command": "docker", "case": "posthog", "lane": "boringcache-docker", "level": "base",
  "capabilities": ["layers"], "runner": "github", "runner_label": "ubuntu-latest",
  "phase": "rolling", "step": 12, "sha": "...",
  "seconds": 212.4, "exit_status": 0, "output_ok": true,
  "provider_reported": { "...": "fields copied verbatim from the product's own evidence" },
  "evidence": ["artifact path of each raw evidence file"],
  "versions": { "boringcache": "1.40.0" },
  "run_url": "https://github.com/boringcache/benchmarks/actions/runs/...", "attempt": 1,
  "started_at": "2026-10-07T10:00:00Z"
}
```

## Lanes per case

| Tool | Cases | Lanes |
| --- | --- | --- |
| docker | posthog, n8n, n8n-runners, n8n-runners-distroless, immich, immich-base-images, mastodon, mastodon-streaming, hugo, duckgres, chroma, linkerd2, qdrant, discourse | `boringcache-docker`, `boringcache-docker-plus` (where it applies), `gha` (type=gha, mode=max), `depot-builder` |
| cargo | deno, zed | `boringcache-cargo`, `boringcache-cargo-plus`, `gha` (sccache GitHub Actions backend), `gha-plus` (+ `Swatinem/rust-cache`), `depot-cache` (sccache WebDAV), `kache` (`kunobi-ninja/kache-action`, RUSTC_WRAPPER compiler cache on the GitHub Actions cache), `mbx` (`jdx/mr-boxington-action`, target + registry + git on the GitHub Actions cache; `plus` level) |
| turbo | n8n | `boringcache-turbo`, `gha` (actions/cache on .turbo), `depot-cache`, `vercel` (OIDC policy "Boringcache turbo") |
| nx | storybook | `boringcache-nx`, `gha`, `depot-cache`; `nx-cloud` last (needs an Nx workspace) |
| bazel | grpc | `boringcache-bazel`, `gha` (disk cache), `buildbuddy`, `nativelink` (R2), `depot-cache` |
| go | hugo | `boringcache-go`, `gha`, `depot-cache` |
| gradle | opentelemetry-java | `boringcache-gradle`, `gha`, `depot-cache` |
| maven | spring-ai | `boringcache-maven`, `gha`, `depot-cache` |
| ccache | obs-studio (Linux) | `boringcache-ccache`, `gha` |
| xcode | obs-studio (macOS) | `boringcache-xcode`, `gha` |
| nix | zed | `boringcache-nix`, `cachix`, `magic-nix-cache` |
| moon | gogs, opencut | `boringcache-moon`, `depot-cache` |
| pants | stackstorm | `boringcache-pants`, `depot-cache`, `nativelink` |
| buck2 | executorch | `boringcache-buck2`, `nativelink` |
| sbt | msgpack-java | `boringcache-sbt`, `gha` (`actions/setup-java` with `cache: sbt`) |

- Depot Cache is configured by hand on the `github` runner with `DEPOT_TOKEN`
  (`cache.depot.dev`, per Depot's docs for each tool).
- The `boringcache-docker-plus` overlays that already exist: posthog (turbo +
  mount cache), chroma (sccache + cargo target/registry/git mounts), mastodon
  (ccache for libvips and ffmpeg + apt cache mounts), immich-base-images (ccache).
  Other Docker cases get `plus` only if upstream already has cache mounts.
- Discourse uses upstream `discourse/discourse` and `discourse/discourse_docker`,
  as the archived repo did.
- Never-run cases (buck2-prelude, pants-jvm, zitadel-moon) come after the above.
- OpenTelemetry Java: both archived lanes cached only Gradle's build cache
  (`caches/build-cache-*` vs the HTTP cache) and neither cached dependencies.
  Under rule 2 the Gradle dependency cache becomes a shared layer for all lanes.

## Runners

`runners.toml` maps keys to labels:

| Key | Label | Size |
| --- | --- | --- |
| `github` | `ubuntu-latest` | GitHub standard |
| `github-arm` | `ubuntu-24.04-arm` | GitHub standard |
| `macos` | `macos-26` | GitHub standard |
| `depot-4` | `depot-ubuntu-24.04-4` | 4 vCPU / 16 GB |
| `depot-8` | `depot-ubuntu-24.04-8` | 8 vCPU / 32 GB |
| `namespace-4` | `namespace-profile-buildkit-4c` | 4 vCPU / 16 GB, Docker "No caching", no volumes |
| `namespace-8` | `namespace-profile-buildkit-8c` | 8 vCPU / 16 GB, Docker "No caching", no volumes |
| `local` | `local` | a laptop or container |

- PostHog runner comparison: both BoringCache Docker lanes on `github`,
  `depot-4/8` and `namespace-4/8`, against `depot-builder` and `gha` on `github`.
- Zed's cargo lanes run on `namespace-8` with no Namespace cache, as upstream
  runs on Namespace (upstream uses up to 16x32; the largest profile here is 8x16).
- Non-Docker lanes do not run on Depot runners, which auto-connect every
  supported tool to Depot Cache.

## Local qualification

Before anything runs on Actions, each tool is qualified locally with the same
`bin/bench` commands, in its own Linux container on the Colima `benchmark`
profile (arm64, 8 CPU, 24 GB), several in parallel. Docker cases get light
checks only. Heavy cases already proven (grpc, zed, deno) get one setup check.
Lanes that only exist on Actions (`gha*`, `depot-builder`, Depot and Namespace
runners) are qualified on Actions. Local builds are arm64 and Actions runners
are amd64, so local runs prove setup, not timings.

## Things to watch

- Namespace is a trial (23 days left on 2026-10-07).
- GitHub Actions cache storage for the repo is 500 GB, raised with the
  enterprise and org limits on 2026-10-09 from the enterprise's 200 GB
  ceiling; retention is 7 days. Before that the repo held 214–218 GB, so GitHub was deleting the
  least recently used entries: the oldest left had been used 95 minutes
  earlier, and lanes idle longer restored nothing (Spring AI and OTel Java
  step 25, Turbo n8n step 35). Each rolling lane also keeps up to about six
  older entries that its newest-first restore never reads, about half of the
  100 largest caches. Reports count a rolling step that restored nothing from
  a lane's Actions cache, after the lane's first step, under "Seed failed",
  not as a timing; records from before 2026-10-08 18:37 carry no
  `cache_restored_key` and are left as they are. Docker lanes on BuildKit's
  `type=gha` cache record no key, so their misses are not visible.
- PostHog (`rolling_stride = 20`), llama.cpp (5), Nix Zed and Cargo Zed (3
  each) move several first-parent commits per rolling step from 2026-10-09,
  because each lands more commits a day than a step can build (PostHog 223 a
  day against about 28 steps). PostHog used 10 for steps 37 and 38 and llama.cpp
  3 for one step before the strides were raised.
- Nix Zed rebuilds both Zed derivations, `zed-editor-deps` and `zed-editor`,
  on every commit in every lane, because the flake puts the commit hash in
  their version. The cache serves the 2,033-path closure (1.3–1.5 GiB) and
  stores the 2.2 GiB of outputs, about a minute of a 60–75 minute job, so the
  total time mostly follows the runner's CPU. At step 1 BoringCache fetched
  the closure in 21 s and Cachix in 52 s, while compiling took 47.6 minutes
  on an AMD EPYC 7763 and 38.5 minutes on an AMD EPYC 9V74. Report its fetch
  and upload phases beside the total.
- The Namespace trial caps 8-core profiles at 16 GB; 32 GB needs a paid plan.
- Zed bundle runs on Depot 8c (32 GB). Its BoringCache lane is
  `boringcache-cargo-phases`: `boringcache cargo --phase restore`, Zed's own
  `script/bundle-linux`, then `--phase save`, so the product's Cargo restore,
  including source freshness, wraps the unmodified bundle script. The
  `depot-actions-cache` lane runs the same script with actions/cache on the same
  four paths, served by Depot's runner cache. Restarted on 2026-10-09 as rolling
  series 2 with the earlier archive-lane records and tags deleted; the archive
  lane rebuilt all 539 crates every step because `boringcache run` applies no
  Cargo freshness. On Namespace 8c (16 GB, and `swapon` is not permitted) that
  lane's rustc was killed for memory three times at step 1. Revisit the
  Namespace cache-volume lane (`namespace-cache`, runner `namespace-8-cache`,
  profile `rust-cache-8c`) on a paid plan with a 32 GB profile.
- Reconcile the lanes added in October once they have enough steps. Zed
  bundle (its own case, now BoringCache archive against Depot's runner cache), PostHog's
  gha-plus and its runner variants, and the Zed Depot 4c pair each sit beside
  a project's main comparison. Reports and the website should show each
  project as one coherent set of lanes, not scattered variants.

## Removed lanes

- Cachely was removed from Bazel - gRPC on 2026-10-08. A standalone S3 cache
  is very slow for chatty adapters like Bazel, which make thousands of small
  cache reads per build. In fresh run 37691560883 its warm took 1,702 s,
  against 135 to 616 s for the other remote-cache lanes (BoringCache,
  BuildBuddy, Depot Cache, NativeLink), and its cold took 3,238 s. Earlier
  runs also logged upload timeouts.
- Bitrise Build Cache was removed from Xcode - OBS on 2026-10-08. With
  Bitrise's documented GitHub Actions setup (CLI 3.17.2, `activate xcode
  --cache`), OBS never configured. CMake identifies the compiler by building a
  throwaway Xcode project by target; Bitrise's `xcodebuild` wrapper added
  `-derivedDataPath` to that call and Xcode rejected it ("The flag -scheme,
  -testProductsPath, or -xctestrun is required when specifying
  -derivedDataPath", exit 64). In the CLI source, `cmd/xcode/xcodebuild.go`
  line 908 adds the flag without the `AcceptsDerivedDataPath()` check that
  `internal/xcelerate/xcodeargs/args.go` defines. With Bitrise's documented
  `--disable-prefix-mapping`, CMake configured but the Swift target
  `mac-camera-extension` failed: cold with "Driver threw invalid absolute
  path 'plugin'", warm with "CAS cannot be initialized from the specified
  '-fcas-*' options: 'plugin': Read-only file system". Setting `SDKROOT` did
  not help: Bitrise's `xcrun` returned the correct SDK. Evidence: fresh run
  37761446458 (default setup, cold and warm failed), debug runs 37768474822
  (default setup with the xcelerate and CMake logs) and 37769123380
  (`--disable-prefix-mapping`).

## Restarted series

- Deno restarted on 2026-10-09 as rolling series 2 on CLI 1.40.2, which fixes
  Cargo source freshness. Series 1 (steps 0 to 12, all on CLI 1.40.1) and the
  fresh run moved to `archive/deno-cli-1.40.1/`, kept but not reported.

## Removed cases

Removed on 2026-10-09. Their records stay in `results/`; reports cover only the
cases defined under `tools/`. Figures are the BoringCache lanes' cold medians
and the upstream commits in the 30 days to 2026-10-09.

- Too few upstream commits to compare, and short builds:
  - Pants: `pants-jvm` (pantsbuild/example-jvm, 0 commits, 65 s cold) and
    `stackstorm` (StackStorm/st2, 1 commit, 29 s);
  - moon: `gogs` (3 commits, 21 s) and `opencut` (1 commit, 19 s);
  - sbt: `msgpack-java` (3 commits, 55 s).
- Builds too short for a cache to matter:
  - Buck2: `buck2-prelude` (13 s cold);
  - Docker: `mastodon-streaming` (28 s cold). The `mastodon` case covers the
    same repository.
- Replaced by a more active project:
  - Nix: `helix` (helix-editor/helix, 5 commits and none since 2026-10-01;
    254 s and 818 s cold), removed once Nix `zed` rolled cleanly.

sbt rolls `lila` (lichess-org/lila) and Pants rolls `backend-ai` (lablup/backend.ai,
`pants check ::`, 234 s cold and 99 s warm when measured); both are backfilled from
2026-10-01. sbt also rolls `play` (playframework/playframework, `sbt test` on its sbt
nightly, 673 s cold and 196 s warm when measured). Nx rolls `storybook` from its last commit before 2026-10-01, and
`BENCH_NX_CACHE_KEYSPACE` in Storybook's Nx global inputs gives every lane
fresh task hashes, as Nx Cloud cannot be emptied. Nix rolls `zed` from
2026-10-01 with Cachix emptied first.

## Version pins

`versions.toml` holds every pin. `bench.yml` pins `boringcache/one@<sha> # vX.Y.Z`
once and passes `cli-version` from `versions.toml`, so laptop and Actions use the
same CLI. Release tooling (`monorepo/bin/sync-benchmark-pins`) is changed later
to update those two lines and run `bin/bench check`. The monorepo product
contract's `maintained_cases` lane names (`docker-tool-cache`,
`docker-mountcache`, …) are updated in the same follow-up.

## Reports and the website

`bin/bench report` writes `data/results.json` and `data/report.md` from
`results/`: measurements, units, levels, sample counts, unmeasured cells, failed
runs, run links. No verdicts. It covers only the cases defined under
`tools/`, so a removed case's records stay in `results/` unreported. The website keeps reading the September
`data/latest/index.json` until its reader
(`web/app/models/reporting/benchmark_comparisons.rb`) switches to the new file;
then `data/latest/` and its old scripts go in one commit.

## Build order

1. `bin/bench` (check, list, run, time, report), `versions.toml`, `runners.toml`,
   `tool.toml` per tool, tests. No cases.
2. One small case per tool, qualified locally in containers, in parallel:
   turbo/n8n, nx/storybook, go/hugo, gradle, maven, cargo (setup check), bazel
   (setup check), ccache, nix, moon, pants, buck2, sbt. Docker locally uses a
   runner-native case (hugo, linkerd2 or qdrant have no `--platform`), because
   posthog's `linux/amd64` build would run under emulation on arm64 Colima.
   xcode needs macOS and is qualified on Actions.
3. `bench.yml` on Actions with docker/posthog (all four Docker lanes) and one
   non-Docker case, to prove the same orchestration there.
4. PostHog runner comparison on Depot and Namespace runners.
5. The remaining cases, each verified locally first.
6. `schedule.yml` per tool once its cases pass on Actions.
7. Follow-ups outside this repo: release pin tooling, product contract lane
   names, website reader, and the `benchmark-workflows` skill (it still
   describes the consolidation's `cases/` and `bin/bench new/start/preserve`).

## What the benchmark is

It runs each product's commands (BoringCache and every competitor lane) on the
same workloads and reports the numbers truthfully: time, storage and
whatever latency each product reports, with the raw evidence kept. Product
numbers are copied into `provider_reported` as reported. Interpreting them is
for people and agents reading the report, not for the harness.
