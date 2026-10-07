# Tools, lanes and cases

Each directory here is a BoringCache adapter command (`docker`, `cargo`, `turbo`, ...).

```
tools/<tool>/
  tool.toml               levels: the capability sets lanes implement
  lanes/<lane>.toml       one provider implementing one level
  <case>/
    case.toml             upstream source, preparation, output check, lane -> runners
    .boringcache.toml     the product plan; [adapters.<tool>].command is the build
    plus/.boringcache.toml  the plan for a plus-level BoringCache lane, if any
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
TURBO_CACHE = "remote:r"
```

| Key | Meaning |
| --- | --- |
| `provider` | `boringcache` runs `boringcache <tool>` in the plan directory; anything else runs the plan's command with the lane's `env` |
| `level` | a level from `tool.toml` |
| `plan` | BoringCache lanes only: plan directory inside the case, default `.` |
| `runners` | runner keys from `runners.toml` the lane may use; omitted means any |
| `actions_only` | the lane needs GitHub Actions and is skipped locally |
| `secrets` | environment the lane reads |
| `env`, `warm.env` | environment for the build, and extra environment for warm |

## case.toml

```toml
repo = "PostHog/posthog"
branch = "master"
start_sha = "<40-character sha>"
prepare = ["git -C upstream submodule update --init"]
check = "docker image inspect posthog:bench"

[runs]
boringcache-docker = ["github", "depot-4"]
gha = ["github"]
```

`prepare` and `check` run with `bash -c` in the run directory, outside the timer.

## Adding

- A case: copy an existing case directory, change `case.toml` and `.boringcache.toml`, run `bin/bench check`.
- A lane: copy a lane file in the same tool, change `provider`, `env` and `runners`.
- A tool: add `tools/<tool>/tool.toml`, a `boringcache-<tool>` lane and one case.

Then run it locally:

```sh
bin/bench run <tool>/<case> --lane <lane>
```
