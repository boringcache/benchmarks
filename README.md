# boringcache/benchmarks

Real-world CI benchmarks across Docker, Rust (`sccache`), and Bazel. GitHub Actions cache vs BoringCache. Same code, same runners, same commits.

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

| Ecosystem | Project | What is cached |
|-----------|---------|----------------|
| Docker | [gohugoio/hugo](https://github.com/gohugoio/hugo) | Go modules, Go build cache |
| Docker | [mastodon/mastodon](https://github.com/mastodon/mastodon) | libvips, ffmpeg, Ruby gems, yarn packages |
| Docker | [immich-app/immich](https://github.com/immich-app/immich) | pnpm store, mise tools |
| Docker | [PostHog/posthog](https://github.com/PostHog/posthog) | pnpm store, turbo build cache, Python runtime, Playwright browsers |
| Rust | [zed-industries/zed](https://github.com/zed-industries/zed) | `~/.cargo/registry`, `~/.cargo/git`, `target/`, native `sccache` |
| Bazel | [grpc/grpc](https://github.com/grpc/grpc) | Bazel remote cache (action cache + CAS) |

For Docker benchmarks, both AC and BC cache layers externally (AC via `type=gha`, BC via `type=registry` through the BoringCache docker-registry proxy). BC additionally caches dependencies inside the build so they persist when layers are invalidated.

## How it works

Each benchmark has two workflows:

- **Actions Cache** baseline
- **BoringCache** candidate

Strategy by ecosystem:

- Docker: Actions uses BuildKit `type=gha`; BoringCache uses a registry proxy (`type=registry`) plus internal dependency caches.
- Rust (`zed-sccache`): Actions uses `actions/cache` for cargo/target/sccache; BoringCache saves cargo/target and uses native `sccache` via BoringCache cache-registry.
- Bazel (`grpc-bazel`): Actions uses `actions/cache` for `~/.cache/bazel`; BoringCache uses `boringcache/bazel-action` remote cache.

Both check out the same pinned commit and run identical build steps on `ubuntu-latest`.

Source pinning model:

- Target source is pinned by `PROJECT_REF` (commit SHA) in each workflow.
- Benchmark logic/Dockerfiles are versioned in this repo for deterministic A/B comparisons across AC vs BC.
- If you want Depot-style benchmark-harness pinning, treat benchmark repos as upstream inputs and pin their commit SHA explicitly when syncing benchmark Dockerfiles/scripts into this repo.

Each workflow runs the same benchmark phases in sequence:

1. **Cold + seed** — `--no-cache` + `cache-to`. Records cold timing and primes remote cache in one pass.
2. **Warm build 1** — `cache-from` + `cache-to`. Measures warm cache performance.
3. **Warm build 2** — Same as warm 1. Measures consistency.
4. **Stale code change** — Mutates one source file and rebuilds with cache enabled. Measures stage dedup/partial warm behavior.
5. **Internal only** — `--no-cache`, targeted build stage. Isolates dependency cache impact.

Builder cache is pruned after cold+seed so warm hits come exclusively from remote cache.

## Tag naming

All BoringCache workflows publish a single `tags_csv` output and use it for purge + storage accounting.

- Docker layer tag: `${BENCHMARK_ID}-docker-layers`
- Run-scoped tag/cache scope: `${BENCHMARK_ID}-run-r${GITHUB_RUN_ID}-a${GITHUB_RUN_ATTEMPT}`
- Internal dependency tags: `${BENCHMARK_ID}-<component>[-version]`

This keeps tag discovery and storage reporting consistent across workflows.

Benchmarks run weekly and can be triggered manually:

```bash
gh workflow run "Run All Benchmarks"
```

Run subsets by category (`docker`, `sccache`, `bazel`) or run everything with `all`.

## License

MIT
