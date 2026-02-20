# boringcache/benchmarks

Real-world Docker builds. GitHub Actions cache vs BoringCache. Same code, same runners, same commits.

## Results

All builds run on `ubuntu-latest` (2 vCPU). Times in seconds.

### Warm builds (all Docker layers cached)

| Project | Cold (no cache) | AC warm | BC warm |
|---------|----------------|---------|---------|
| [gohugoio/hugo](https://github.com/gohugoio/hugo) | 2m 48s | 2s | 6s |
| [immich-app/immich](https://github.com/immich-app/immich) | 2m 33s | 4s | 7s |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | 8m 21s | 4s | 7s |
| [PostHog/posthog](https://github.com/PostHog/posthog) | 6m 6s | 13s | 10s |

Both AC and BC achieve near-instant warm builds when Docker layers are cached. The difference is single-digit seconds.

### Stale Docker builds (layers invalidated, deps unchanged)

This is the scenario that matters: a Dockerfile change, base image update, or new branch invalidates all Docker layers, but your dependencies haven't changed. This happens frequently in real CI.

| Project | AC (rebuild from scratch) | BC (deps cached) | BC faster by |
|---------|--------------------------|-------------------|-------------|
| [gohugoio/hugo](https://github.com/gohugoio/hugo) | 2m 44s | **35s** | **79%** |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | 7m 56s | **1m 48s** | **77%** |
| [PostHog/posthog](https://github.com/PostHog/posthog) | 6m 3s | **4m 32s** | **25%** |
| [immich-app/immich](https://github.com/immich-app/immich) | 2m 22s | **2m 28s** | ~same |

When Docker layers go stale, AC rebuilds everything from scratch. BC caches dependencies inside the Dockerfile (Go modules, Ruby gems, pnpm stores, Python packages) so they survive layer invalidation.

### Internal-only builds (deps cached, no Docker layers)

Targeted build stages that isolate dependency cache impact.

| Project | AC | BC | BC faster by |
|---------|-----|-----|-------------|
| [gohugoio/hugo](https://github.com/gohugoio/hugo) | 2m 39s | **30s** | **81%** |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | 3m 15s | **1m 31s** | **53%** |
| [PostHog/posthog](https://github.com/PostHog/posthog) | 4m 39s | **1m 48s** | **61%** |
| [immich-app/immich](https://github.com/immich-app/immich) | 50s | **48s** | ~same |

## What's being benchmarked

| Project | What BC caches inside the Dockerfile |
|---------|--------------------------------------|
| [gohugoio/hugo](https://github.com/gohugoio/hugo) | Go modules, Go build cache |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | libvips, ffmpeg, Ruby gems, yarn packages |
| [immich-app/immich](https://github.com/immich-app/immich) | pnpm store, mise tools |
| [PostHog/posthog](https://github.com/PostHog/posthog) | pnpm store, turbo build cache, Python runtime, Playwright browsers |

Both AC and BC also cache Docker layers externally (AC via `type=gha`, BC via `type=registry` through the BoringCache docker-registry proxy). The difference is that BC *also* caches dependencies inside the build, so they persist when layers are invalidated.

## How it works

Each project has two workflows:

- **Actions Cache** (`type=gha`) — Docker layer cache via GitHub Actions cache
- **BoringCache** (`type=registry`) — Docker layer cache via BoringCache registry proxy + dependency caching inside Dockerfiles

Both check out the same pinned commit and run identical build steps on `ubuntu-latest`.

Each workflow runs these build phases in sequence:

1. **Cold baseline** — `--no-cache`, no remote cache. Measures raw build time.
2. **Seed cache** — `--no-cache` + `cache-to`. Populates the remote cache.
3. **Warm build 1** — `cache-from` + `cache-to`. Measures warm cache performance.
4. **Warm build 2** — Same as warm 1. Measures consistency.
5. **Stale Docker** — `--no-cache`, no layer cache, but BC internal deps cached. Simulates Dockerfile changes.
6. **Internal only** — `--no-cache`, targeted build stage. Isolates dependency cache impact.

Builder cache is pruned between seed and warm builds so warm hits come exclusively from the remote cache.

Benchmarks run weekly and can be triggered manually:

```bash
gh workflow run "Run All Benchmarks"
```

## License

MIT
