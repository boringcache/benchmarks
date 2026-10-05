# Helix / Nix

Status: source-pinned evaluation; execution is blocked by `case.json`.
No benchmark measurements have been collected.

Source: [helix-editor/helix at `ba40e547426b0f9896c8bdc699a4ab11f2b37dbc`](https://github.com/helix-editor/helix/tree/ba40e547426b0f9896c8bdc699a4ab11f2b37dbc).

Upstream recipe:

- [flake.nix](https://github.com/helix-editor/helix/blob/ba40e547426b0f9896c8bdc699a4ab11f2b37dbc/flake.nix)
- [flake.lock](https://github.com/helix-editor/helix/blob/ba40e547426b0f9896c8bdc699a4ab11f2b37dbc/flake.lock)
- [.github/workflows/cachix.yml](https://github.com/helix-editor/helix/blob/ba40e547426b0f9896c8bdc699a4ab11f2b37dbc/.github/workflows/cachix.yml)

## Workload

Proposed timed command: `nix build .#default -L`. Use the committed `flake.lock`
and the same pinned Nix version on Linux x86_64 in both provider arms. Nix
installation and the declared common dependency-store preparation are outside
timing. Do not update the lockfile during an observation.

The default flake package is Helix. Include its runtime files and grammars in output verification.

## Comparison

Compare BoringCache's Nix binary cache with a benchmark-owned Cachix cache.
Start with two cold builds and their identical-source warm replays per provider.
Both upstream workflows use Cachix; their public caches are not benchmark seeds.
Record a substituter configuration patch in both arms so public caches cannot
satisfy the measured package output. Keep any public dependency-cache use equal
and record the exact initial dependency-store closure. Keep signature checking
enabled and scope provider trust to the declared cache.

Each warm observation uses a fresh store with only the declared dependency
baseline. Require the same output store path and closure NAR hashes, and forbid
local builds while proving substitution from the selected provider. Check the
package executable after restoration. Wait for closure publication before
starting the warm worker. Report build/reuse and upload completion separately.
Provider storage counts must identify their scope; missing data stays unmeasured.

Follow [the shared case process](../../docs/process.md). The case has no schedule
or published results. `case.json` lists the remaining activation checks.
