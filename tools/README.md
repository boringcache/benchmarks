# Tools, lanes and cases

Each directory here is a BoringCache adapter command (`docker`, `cargo`, `turbo`, ...).

Case `mise.toml` files pin Node 22.23.4, 24.22.1 or 26.12.1 and Go 1.27.3,
which include the October 2026 certificate security updates. See the
[Node security release](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases)
and [Go release history](https://go.dev/doc/devel/release).
Java cases run `tools/shared/JavaCaTrust.java --apply` with every selected JDK
after installation and before workload downloads. It removes only the two
reviewed eMudhra root fingerprints, preserves unrelated entries and permissions,
and saves the original store without replacing an existing backup. A repair
failure stops preparation. The same preparation applies to every provider lane.
Earlier result records retain their original harness and toolchain selection.

The Backend.AI Pants case installs the exact CPython version required by the
checked-out source's `pants.toml`. This applies to every provider lane and keeps
fresh runs on the original interpreter while rolling runs follow upstream.
Pants discovers the installed interpreter through a link in the run's `.bin`
directory so its isolated probes do not need to execute mise shims.

```
tools/<tool>/
  tool.toml               display name and levels: the capability sets lanes implement
  lanes/<lane>.toml       one provider implementing one level
  <case>/
    case.toml             upstream source, preparation, output check, lane -> runners
    .boringcache.toml     the product plan; [adapters.<tool>].command is the build
    plus/.boringcache.toml  the plan for a plus-level lane, if any (same root-relative paths as the base plan)
    overlay/              upstream changes a lane needs
```

## tool.toml

```toml
[levels]
base = ["layers"]
plus = ["layers", "tool-cache", "mount-cache"]
```

An optional `setup` list applies to every lane of the tool, for example `setup = ["nix"]` so every Nix lane installs Nix the same way.

## lanes/<lane>.toml

```toml
provider = "depot"
level = "base"
runners = ["github"]
secrets = ["DEPOT_TOKEN"]

[env]
TURBO_API = "https://cache.depot.dev"
TURBO_TOKEN = "${DEPOT_TOKEN}"

[warm.env]
TURBO_CACHE = "local:rw,remote:r"
```

| Key | Meaning |
| --- | --- |
| `provider` | `boringcache` runs `boringcache <tool>` in the plan directory; anything else runs the plan's command with the lane's `env` |
| `level` | a level from `tool.toml` |
| `plan` | which plan the lane uses, default `.`; `plus` for a plus-level lane. It is copied to the run directory as its only `.boringcache.toml` |
| `runners` | runner keys from `runners.toml` the lane may use; omitted means any |
| `actions_only` | the lane needs GitHub Actions and is skipped locally |
| `secrets` | environment the lane reads |
| `env`, `warm.env` | environment for the build, and extra environment for warm |
| `paths` | GitHub Actions cache lanes: tool cache paths to save and restore, relative to the run directory |
| `args`, `warm.args` | arguments appended to the plan command, and the warm replacement (for example `--cache-from`/`--cache-to`) |
| `setup` | workflow setup the lane needs: `buildx` (Buildx builder), `actions-runtime` (Actions cache credentials for type=gha and sccache), `cache-dance` (restore the plan Dockerfile cache mounts from the Actions cache after the timer starts, recording the matched key, and save them after the job), `namespace-cache` (mount the case `shared` paths from the runner profile Namespace cache volume), `ghcr` (log in to GHCR), `depot` (Depot CLI), `vercel` (Vercel Remote Cache token through OIDC), `namespace` (Namespace CLI and remote Buildx builder), `nix` (Nix), `cachix` (Cachix CLI and substituter, no push), `bitrise` (Bitrise Build Cache CLI; the lane activates Bazel, Gradle or Xcode), `nativelink` (local NativeLink server backed by R2) before the timer; `kache` and `mbx` run their actions after the timer starts because they restore cache data |
| `phases` | BoringCache lanes only: run `boringcache <tool> --phase restore`, then the plan command, then `--phase save` (no save on warm), for upstream scripts that run several tool commands, such as Zed's bundle script with Cargo |
| `program`, `replaces` | `program` replaces the leading `replaces` words of the plan command, for example `depot` for `docker buildx` or `mbx` for `cargo` |
| `wrap`, `cold.wrap` | command prefix around the build, for example `cachix watch-exec <cache> --` on cold |
| `finish`, `cold.finish` | commands run after a successful build inside the timer, for example a provider push that would otherwise happen after the job |
| `cli_args` | BoringCache lanes only: flags passed to `boringcache <tool>`, such as `--on-demand`; records carry them in `product_args` and the report shows them beside the CLI version |
| `experimental` | `true` marks an experimental lane, such as the `--on-demand` lanes; records carry `"experimental": true` and the public report leaves them out |
| `label` | job label for a BoringCache lane, needed when two BoringCache lanes share a runner, for example `boringcache on-demand` |
| `reads` | BoringCache lanes only: `{ lane = "<lane>", runner = "<runner key>" }`, a source with the same level, plan, env and `cli_args`. Sample builds use its completed rolling cache with `--read-only`; records include the selected source run and commit. Legacy rolling builds using this setting retain their original previous-step behavior. |
| `cache_keys` | GitHub Actions cache key prefixes the lane's own action saves under, naming `${BENCH_SCOPE}`, such as `kache-${BENCH_SCOPE}-v`; after a rolling step the publish job keeps only the newest entry under each |
| `post_job_save` | actions (`owner/repo`) or step ids that save the lane cache only after the job, such as `reproducible-containers/buildkit-cache-dance`; the collect job records their logged durations as `post_job_save_seconds` and the final `job_conclusion`. Reports include these durations and exclude failed jobs from timings and matched steps. |
| `probe` | credential and connection checks for a preflight run; they run in the run directory without a checkout |
| `prepare`, `cold.prepare` | untimed commands the lane runs after the case `prepare`, for every phase or one phase |

## case.toml

```toml
repo = "n8n-io/n8n"
branch = "master"
start_sha = "<40-character sha>"
directory = "upstream"
prepare = ["mise trust && mise install"]
check = "test -s upstream/packages/cli/dist/index.js"
shared = [".pnpm-store"]

[env]
PNPM_CONFIG_STORE_DIR = "${BENCH_DIR}/.pnpm-store"

[runs]
boringcache-turbo = ["github", "local"]
gha = ["github"]
```

| Key | Meaning |
| --- | --- |
| `project` | the project this case belongs to, default the case name; one project run covers every case, lane and runner of the project |
| `repo`, `branch` | upstream GitHub repository and the branch rolling follows |
| `start_sha` | latest first-parent commit on `branch` when the case is added; fresh runs build it and rolling starts from it |
| `rolling_series` | optional integer above 1 that restarts rolling from `start_sha` on new scopes, `<lane>-<runner>-rolling-<series>`, so every lane's cache starts empty; records of earlier series are not read |
| `rolling_stride` | optional integer above 1: each rolling step moves this many first-parent commits, for upstreams that land more commits a day than a step can build; every lane builds the same commits |
| `directory` | where the build command runs, relative to the plan directory, default `.` |
| `prepare` | untimed commands before the build |
| `setup` | shared setup names applied to every lane of this case, such as `ghcr` when every lane publishes its output image |
| `check` | untimed output check after the build |
| `shared` | paths every lane caches (dependencies), relative to the run directory |
| `exclude` | paths under a cached path that Actions cache lanes leave out, relative to the run directory, matching the `exclude` of the BoringCache plan entry |
| `env` | environment for every lane; `${BENCH_DIR}` is the run directory; `${BENCH_SCOPE}` is the run-scoped cache identity (tool, case, lane, runner, run) |
| `runs` | lane name to the runner keys it runs on |
| `script` | optional command every lane runs instead of the plan command, for a build of several tool commands, such as `["bash", "../overlay/fuzz-smoke.sh"]`; BoringCache lanes get `BENCH_BORINGCACHE`, the `boringcache <tool>` prefix with the lane's `cli_args` and `--read-only` on warm, and the script runs each tool command through it with `--skip-restore` and `--skip-save` so only the first restores and the last saves; other lanes run the tool directly |
| `samples` | lane name to runner keys from `runs` reserved for `mode=sample`; excluded from fresh and rolling matrices. Weekly samples select the latest completed GitHub source commit, including when upstream has no newer commit. |
| `nightly` | lane name to runner keys from `runs` that roll only at the first rolling step of each UTC day, on their usual fixed scope; their records carry `"cadence": "nightly"` and the report matches them with each other under the runner `nightly`, without holding back the lanes that run every step |

A `mise.toml` beside `case.toml` pins the case toolchain; it is copied into the run directory.

Each phase runs in `<work>/<tool>/<case>/` (`.work` locally, `$HOME/w` on Actions, or `BENCH_WORK`), rebuilt from scratch for every phase at the same short path, as an upstream checkout would be, so tools that key caches or names on absolute paths behave the same: the plans with run-scoped tags, `overlay/`, and the upstream checkout in `upstream/`. `prepare` and `check` run there with `bash -c`, outside the timer, so their paths start at the run directory (`upstream/...`), not at the plan directory.

Mastodon plus applies its compiler-cache patch to the checked-out upstream
Dockerfile during preparation, preserving that commit's runtime and library
versions. Ferrum verifies each fuzz executable after its smoke run, records the
completed target in `fuzz-verified`, then removes that executable and its package
objects before the next target. These files were already excluded from every
provider's cache; the shared dependency artifacts remain. Failed targets stop
the script before verification or cleanup.

## Adding

- A case: copy an existing case directory, change `case.toml` and `.boringcache.toml`, run `bin/bench check`.
- A lane: copy a lane file in the same tool, change `provider`, `env` and `runners`.
- A tool: add `tools/<tool>/tool.toml`, a `boringcache-<tool>` lane and one case.

Then run it locally, directly or with each phase in a fresh container:

```sh
bundle install
bin/bench run <tool>/<case> --lane <lane>
bin/bench image
bin/bench run <tool>/<case> --lane <lane> --container
```

`--container` reads BoringCache tokens from `.env` (`BORINGCACHE_RESTORE_TOKEN`, `BORINGCACHE_SAVE_TOKEN`).

## runners.toml

```toml
[depot-4]
label = "depot-ubuntu-24.04-4"
machine = "depot 4c"
env = { BORINGCACHE_EPHEMERAL_PRIVILEGED_RUNNER = "1" }
```

`label` is the `runs-on` value and `machine` names the provider and core count in job labels (GitHub standard runners for public repositories: 4 cores on Linux, 3 on macOS). Docker cases run on the architectures their mirrored upstream job builds, each natively on its own runner (`github` amd64, `github-arm` arm64), so plans carry no `--platform`. `env` applies to every phase on that runner; Depot and Namespace runners are single-tenant and destroyed after the job, which is what the CLI asks before it starts managed BuildKit there.

## On GitHub Actions

`.github/workflows/project.yml` runs one tool for one project, named `<tool> - <project>` (for example `Docker - PostHog`, `Go - Hugo`, `Turbo - n8n`); the tool is the grouping and a project can appear under several tools. `bin/bench matrix <project> --tool <tool>` turns every matching case into one flat list of jobs named `cold: [case ·] machine · lane` and `warm: ...` (for example `cold: github 4c · boringcache`, `warm: github arm 4c · boringcache plus`, `cold: n8n-runners · github 4c · gha`). All `cold` jobs run side by side, then all `warm` jobs. Each job calls `.github/actions/phase`, which runs the same `bin/bench` steps as a local run. A job only receives the secrets its lane lists. Every BoringCache plan sets `fail-on-cache-error = true`, so a cache save or restore that fails fails the phase instead of falling back silently. A product build that fails, or fails its output check, is still recorded with its `exit_status` and `output_ok` and uploaded, then the job fails with an error annotation, in every lane. Setup, prepare and record errors still fail the job, because then nothing was measured.

```sh
gh workflow run project.yml -f tool=Docker -f project=Hugo
gh workflow run project.yml -f tool=Nix -f project=Zed -f mode=preflight
```

A preflight run (`<tool> - <project> (preflight)`) runs every lane's setup and `probe` with the lane's secrets and no checkout or build, so missing keys and auth problems show up in minutes. A cold phase refuses to run on a rerun attempt, because the run's cache scope may already hold data; dispatch a fresh run instead.

The collect job runs on main and branches, adds post-job save durations, and uploads `recorded-results-<attempt>`. The publish job downloads that artifact and writes records only on main. Branch results require review before they are added to the repository.

## Weekly runner samples

`samples.yml` dispatches PostHog on Depot, Zed on Namespace, and Chroma on Blacksmith every Monday at 02:31 UTC. Each also rebuilds the same commit on GitHub using the same BoringCache scope. Regular GitHub rolling builds continue producing that scope. Sample and rolling workflows share a project concurrency group, and the scheduler treats both as active work. A sample refuses an excluded or failed latest source, or a source older than the latest recorded project step.

The cache tag is mutable; selecting a source record is not an immutable cache-version pin. Serialization prevents this repository's normal rolling workflow from publishing during the sample. External writes and a cancelled run that published cache without recording its result remain limits of source provenance. Sample records retain the selected source run, commit, scope and CLI version. Repeated samples have separate run scopes and do not advance rolling.

Native comparisons use Depot's persistent remote Docker builder, a Namespace cache volume, and Blacksmith's persistent Docker builder. Sample phases do not execute Depot's cold cache reset. Namespace mounts the dependency stores, Cargo target directory and sccache directory using [nscloud-cache-action](https://namespace.so/docs/reference/github-actions/nscloud-cache-action). Blacksmith uses the pinned official [setup-docker-builder action](https://github.com/useblacksmith/setup-docker-builder); setup and post-job persistence are included in its timed operations.

For a changed-source sample, pass `-f sha=<full upstream commit SHA>`. The commit must be newer than the selected GitHub cache source and on the upstream branch's first-parent history. This does not wait for the rolling stride or advance rolling. Every sample lane builds the requested commit. BoringCache restores the selected source cache without publishing; native providers retain and update their own caches. Repeated changed-source samples therefore keep using the latest regular GitHub cache, while native cache history can advance between samples. Records distinguish the build `sha` from `cache_source.sha`.

These native caches retain their own history between samples. BoringCache samples rebuild the commit just built by GitHub and time restore plus build; native samples time restore, build and save. The report lists each run and its operations without calculating a cache-only speedup between those histories. Docker base and plus configurations remain separate levels. The Namespace BoringCache profile has swap configured; the label-configured cache-volume runner does not specify swap. Their timings must not be described as identical-resource cache comparisons. Provider selection matches the project's provider, not its exact upstream machine specification.

Manual samples can select configured larger runners:

```sh
gh workflow run project.yml --ref main -f tool=Docker -f project=chroma -f mode=sample -f runner=blacksmith-8
gh workflow run project.yml --ref main -f tool=Rust/Cargo -f project=zed -f mode=sample -f lane=boringcache-cargo-plus-reader -f runner=namespace-8
```

Use the exact tool title and project key so manual samples share rolling concurrency. Namespace's 8-core BoringCache profile and 8-core cache-volume runner are separate configurations; matching core count alone does not establish matching memory or swap.

## Daily dependency benchmarks

`deps.yml` runs at 03:17 UTC daily, rotating one of the four dependency cases per day across GitHub, Depot, Namespace and Blacksmith. Each case installs the before-lockfile snapshot, restores it for the after-lockfile install, saves the updated cache, then restores and verifies that cache in a new job. Manual runs can select a case and runner keys; an empty case runs all cases.

Additional verification jobs restore the GitHub-produced BoringCache on all three other providers. The actions/cache comparison runs across providers only where they share the same backend. Depot and Blacksmith provide separate Actions-compatible cache stores; records identify those backends instead of calling every actions/cache invocation GitHub storage.

The dependency report groups exact source pairs, consumer CPU, CLI/action version, backend and cache source. Only complete passing seed, update and verification cycles contribute timings. Failed or missing stages count as failed samples. For cross-provider rows, install and save describe the source runner; the final restore describes the consumer runner. Records retain the matched Actions key and harness commit. Native Namespace volumes and Blacksmith Docker volumes are build experiments, not dependency archive backends.
