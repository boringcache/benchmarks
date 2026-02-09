# boringcache/benchmarks

**Cache once. Reuse everywhere.**

Real-world CI benchmarks showing BoringCache performance on popular open-source projects. Baselines run with **no cache** to show the full impact.

## Results

| Project | Baseline (no cache) | BoringCache | Savings |
|---------|-------------------|-------------|---------|
| [grpc/grpc](https://github.com/grpc/grpc) | 26m 34s | 1m 46s | **93%** |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) (Docker) | 9m 24s | 0m 58s | **89%** |
| [bevyengine/bevy](https://github.com/bevyengine/bevy) | 9m 10s | 1m 20s | **85%** |
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | 5m 22s | 0m 56s | **82%** |
| [immich-app/immich](https://github.com/immich-app/immich) | 3m 58s | 1m 48s | **55%** |
| [PostHog/posthog](https://github.com/PostHog/posthog) | 8m 6s | 6m 53s | **15%** |

> Results are from the latest CI runs. Baselines use no caching. BoringCache numbers reflect warm-cache performance.

## Projects

### Docker Builds

| Project | Stars | What's cached | Action |
|---------|-------|--------------|--------|
| [PostHog/posthog](https://github.com/PostHog/posthog) | 31k | pnpm, Python, turbo, Playwright | `docker-action` + deps inside Dockerfile |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | 50k | libvips, ffmpeg, gems, yarn | `docker-action` + deps inside Dockerfile |
| [grpc/grpc](https://github.com/grpc/grpc) | 44k | Bazel build outputs | `docker-action` + deps inside Dockerfile |
| [immich-app/immich](https://github.com/immich-app/immich) | 60k | pnpm store, mise tools | `docker-action` + deps inside Dockerfile |
| [apache/kafka](https://github.com/apache/kafka) | 32k | Gradle caches, Docker layers | `action` + `docker-action` |

### Rust

| Project | Stars | What's cached | Action |
|---------|-------|--------------|--------|
| [bevyengine/bevy](https://github.com/bevyengine/bevy) | 44k | cargo registry, target, sccache | `rust-action` |
| [zed-industries/zed](https://github.com/zed-industries/zed) | 75k | cargo registry, target, sccache | `rust-action` |

### Ruby

| Project | Stars | What's cached | Action |
|---------|-------|--------------|--------|
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | 50k | gem bundle | `ruby-action` |
| [discourse/discourse](https://github.com/discourse/discourse) | 46k | gem bundle | `ruby-action` |

### Node.js

| Project | Stars | What's cached | Action |
|---------|-------|--------------|--------|
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | 174k | pnpm store, node_modules, turbo | `nodejs-action` |
| [calcom/cal.com](https://github.com/calcom/cal.com) | 40k | yarn cache, node_modules | `nodejs-action` |

## How It Works

Each project has two workflow files:

- `{project}-baseline.yml` — **No cache** (clean build from scratch)
- `{project}-boringcache.yml` — Uses the appropriate [BoringCache action](https://github.com/boringcache)

Both workflows:
1. Check out the target repo at a **pinned commit** (reproducible)
2. Run the same build steps
3. Record step-level timing
4. Output results to workflow summary

## Running Benchmarks

Benchmarks run on a weekly schedule and can be triggered manually:

```bash
# Run a specific benchmark
gh workflow run "PostHog - BoringCache"

# Run all benchmarks
gh workflow run "Run All Benchmarks"
```

## License

MIT
