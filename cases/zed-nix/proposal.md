# Zed / Nix

Status: source-pinned evaluation; execution is blocked by `case.json`.
No benchmark measurements have been collected.

Source: [zed-industries/zed at `96837d78cb0f2128c1965716f8df56b8aea59742`](https://github.com/zed-industries/zed/tree/96837d78cb0f2128c1965716f8df56b8aea59742).

Upstream recipe:

- [flake.nix](https://github.com/zed-industries/zed/blob/96837d78cb0f2128c1965716f8df56b8aea59742/flake.nix)
- [flake.lock](https://github.com/zed-industries/zed/blob/96837d78cb0f2128c1965716f8df56b8aea59742/flake.lock)
- [.github/workflows/nix_build.yml](https://github.com/zed-industries/zed/blob/96837d78cb0f2128c1965716f8df56b8aea59742/.github/workflows/nix_build.yml)

## Workload

Proposed timed command: `nix build .#default -L`. Use the committed `flake.lock`
and the same pinned Nix version on Linux x86_64 in both provider arms. Nix
installation and the declared common dependency-store preparation are outside
timing. Do not update the lockfile during an observation.

The existing `zed` case measures Cargo. This case measures the Nix package. Upstream also uses Namespace store caching and a Cachix push filter; neither is an equivalent provider comparison. Declare any changes to those settings.

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
