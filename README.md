# boringcache/benchmarks

Real-world CI builds. GitHub Actions cache vs BoringCache. Same code, same runners, same commits.

## Results

| Project | Cold build | BoringCache warm | Faster |
|---------|------------|------------------|--------|
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | 9m 24s | 0m 58s | **89%** |
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | 5m 37s | 0m 56s | **83%** |
| [PostHog/posthog](https://github.com/PostHog/posthog) | 8m 6s | 3m 6s | **62%** |
| [immich-app/immich](https://github.com/immich-app/immich) | 3m 52s | 1m 42s | **56%** |
| [gohugoio/hugo](https://github.com/gohugoio/hugo) | 8m 48s | 1m 27s | **84%** |

Each benchmark workflow runs cold + warm1 + warm2 in sequence on `ubuntu-latest`.
Docker benchmark workflows also include one extra stale Docker cache run (`--no-cache`) so we can compare:
- warm cache speedup
- internal-only speedup (BoringCache with Docker layer cache disabled)
- stale/no-layer-cache behavior across AC vs BC

Tag naming convention for benchmark Dockerfiles:
- use logical cache tags only (`mastodon-gems`, `ffmpeg-8.0`, `posthog-pnpm`)
- do not embed `${TARGETPLATFORM}` or values like `linux/amd64` in tag names
- let BoringCache CLI append platform suffixes automatically

## What's being benchmarked

### Active benchmark set

The benchmark suite is intentionally focused on projects that are representative for standard CI runners (`ubuntu-latest`) and cache-heavy dependency graphs.

| Project | What's cached |
|---------|--------------|
| [PostHog/posthog](https://github.com/PostHog/posthog) | Docker layers, pnpm store, Python runtime, turbo build cache, Playwright browsers |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | libvips, ffmpeg, Ruby gems, yarn packages |
| [immich-app/immich](https://github.com/immich-app/immich) | pnpm store, mise tools |
| [gohugoio/hugo](https://github.com/gohugoio/hugo) | Go modules and Docker layer cache |
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | pnpm store and turbo build cache |

Friday Pulse is tracked as a customer benchmark separately and can be merged into this index when we finalize a dedicated workflow pair.

## How it works

Each project has two workflows:

- **Actions Cache** — native GitHub Actions cache behavior
- **BoringCache** — uses BoringCache for cache persistence and restores

Both check out the same pinned commit and run identical build steps on `ubuntu-latest`.

Benchmarks run weekly and can be triggered manually:

```bash
gh workflow run "PostHog - BoringCache"
gh workflow run "Run All Benchmarks"
```

## Web index JSON

This repository publishes a web-consumable benchmark index at:

`data/latest/index.json`

The `Publish Benchmark Index` workflow refreshes this file from the latest successful benchmark artifacts and commits changes to `main`.

For Mastodon and PostHog, the index publisher also infers latest Depot `Benchmark` run timings from:
- `depot/benchmark-mastodon`
- `depot/benchmark-posthog`

These are added as optional metadata fields in `index.json` for comparison use without changing the current card schema.

## License

MIT
