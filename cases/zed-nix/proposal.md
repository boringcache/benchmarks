# Zed / Nix

Status: workflow implemented; cold/warm qualification is pending.
No benchmark measurements have been collected.

Source: [zed-industries/zed at `96837d78cb0f2128c1965716f8df56b8aea59742`](https://github.com/zed-industries/zed/tree/96837d78cb0f2128c1965716f8df56b8aea59742).

Upstream recipe:

- [flake.nix](https://github.com/zed-industries/zed/blob/96837d78cb0f2128c1965716f8df56b8aea59742/flake.nix)
- [flake.lock](https://github.com/zed-industries/zed/blob/96837d78cb0f2128c1965716f8df56b8aea59742/flake.lock)
- [.github/workflows/nix_build.yml](https://github.com/zed-industries/zed/blob/96837d78cb0f2128c1965716f8df56b8aea59742/.github/workflows/nix_build.yml)

## Workload

Timed operation: the pinned default package derivation, built through `nix build`. Use the committed `flake.lock`
and the same pinned Nix version on Linux x86_64 in both provider arms. Nix
installation and realization of the package derivation's build dependencies are
outside timing. Do not update the lockfile during an observation.

The existing `zed` case measures Cargo. This case measures the Nix package. Upstream also uses Namespace store caching and a Cachix push filter; neither is an equivalent provider comparison. Declare any changes to those settings.

## Comparison

Compare BoringCache's Nix binary cache with a benchmark-owned Cachix cache.
Start with two cold builds and their identical-source warm replays per provider.
Both upstream workflows use Cachix; their public caches are not benchmark seeds.
The runner ignores flake-provided cache settings in both arms. Cold builds disable
substitution after dependency preparation. Warm builds allow only the selected
provider and disable local and remote builders. The runner records dependency
closure NAR hashes and rejects a package output already present before timing. Keep signature checking
enabled and scope provider trust to the declared cache.

Each warm observation uses a fresh store with only the declared dependency
baseline. Require the same output store path and closure NAR hashes, and forbid
local builds while proving substitution from the selected provider. Check the
package executable after restoration. Wait for closure publication before
starting the warm worker. Report build/reuse and upload completion separately.
Provider storage counts must identify their scope; missing data stays unmeasured.

Follow [the shared case process](../../docs/process.md). The case has no schedule
or published results. Set `CACHIX_CACHE` and `CACHIX_AUTH_TOKEN` on the benchmark repository.
The shared `nix-fresh-benchmark.yml` runs both providers. A single-provider
dispatch is a correctness screen and leaves the comparison incomplete.
Cachix shares content-addressed objects across series; no empty-remote-store
claim is made. The cold build does not read a package substitute.

Complete two cold/warm samples per provider, retain post-job publication evidence,
and check exact dependency and output closure equality before publication.
