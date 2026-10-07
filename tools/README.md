# Tools, lanes and cases

Each directory here is a BoringCache adapter command (`docker`, `cargo`, `turbo`, ...).

```
tools/<tool>/
  tool.toml               levels: the capability sets lanes implement
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
| `repo`, `branch` | upstream GitHub repository and the branch rolling follows |
| `start_sha` | first-parent commit on `branch` as of 2026-09-30 23:59 UTC |
| `directory` | where the build command runs, relative to the plan directory, default `.` |
| `prepare` | untimed commands before the build |
| `check` | untimed output check after the build |
| `shared` | paths every lane caches (dependencies), relative to the run directory |
| `env` | environment for every lane; `${BENCH_DIR}` is the run directory |
| `runs` | lane name to the runner keys it runs on |

A `mise.toml` beside `case.toml` pins the case toolchain; it is copied into the run directory.

Each phase runs in `.work/<tool>/<case>/<lane>/`, rebuilt from scratch for every phase at the same path, as on Actions, so tools that key caches on absolute paths behave the same: the plans with run-scoped tags, `overlay/`, and the upstream checkout in `upstream/`. `prepare` and `check` run there with `bash -c`, outside the timer, so their paths start at the run directory (`upstream/...`), not at the plan directory.

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
env = { BORINGCACHE_EPHEMERAL_PRIVILEGED_RUNNER = "1" }
```

`label` is the `runs-on` value. `env` applies to every phase on that runner; Depot and Namespace runners are single-tenant and destroyed after the job, which is what the CLI asks before it starts managed BuildKit there.

## On GitHub Actions

`.github/workflows/project.yml` runs one case: `bin/bench matrix <tool>/<case>` turns `[runs]` into a flat list of lane and runner jobs, all `cold` jobs run side by side, then all `warm` jobs. Each job calls `.github/actions/phase`, which runs the same `bin/bench prepare`, `start`, `build` and `record` steps as a local run, with the `boringcache/one` Action for BoringCache lanes and `actions/cache` for the paths other lanes cache. A job only receives the secrets its lane lists.

```sh
gh workflow run project.yml -f case=docker/posthog
gh workflow run project.yml -f case=docker/posthog -f lane=boringcache-docker -f runner=depot-4
```
