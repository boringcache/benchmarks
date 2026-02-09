# boringcache/benchmarks

Real-world CI builds. No cache vs BoringCache. Same code, same runners, same commits.

## Results

| Project | No cache | BoringCache | Faster |
|---------|----------|-------------|--------|
| [grpc/grpc](https://github.com/grpc/grpc) | 26m 34s | 1m 46s | **93%** |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) (Docker) | 9m 24s | 0m 58s | **89%** |
| [bevyengine/bevy](https://github.com/bevyengine/bevy) | 10m 7s | 1m 20s | **86%** |
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | 5m 37s | 0m 56s | **83%** |
| [zed-industries/zed](https://github.com/zed-industries/zed) | 5m 18s | 1m 30s | **71%** |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) (Ruby) | 1m 37s | 0m 31s | **68%** |
| [discourse/discourse](https://github.com/discourse/discourse) | 1m 48s | 0m 44s | **59%** |
| [immich-app/immich](https://github.com/immich-app/immich) | 3m 52s | 1m 42s | **56%** |
| [calcom/cal.com](https://github.com/calcom/cal.com) | 2m 57s | 2m 23s | **19%** |
| [PostHog/posthog](https://github.com/PostHog/posthog) | 8m 6s | 6m 53s | **15%** |

Baselines build from scratch every time. BoringCache numbers reflect warm-cache runs.

## What's being benchmarked

### Docker Builds

Multi-stage Docker builds with dependencies cached inside the Dockerfile using the BoringCache CLI.

| Project | What's cached |
|---------|--------------|
| [PostHog/posthog](https://github.com/PostHog/posthog) | pnpm store, Python runtime, turbo build cache, Playwright browsers |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | libvips, ffmpeg, Ruby gems, yarn packages |
| [grpc/grpc](https://github.com/grpc/grpc) | Bazel build outputs (5,500+ C++ compilation targets) |
| [immich-app/immich](https://github.com/immich-app/immich) | pnpm store, mise tools |

### Rust

Cargo builds with `rust-action` caching the registry, build target, and sccache.

| Project | |
|---------|--|
| [bevyengine/bevy](https://github.com/bevyengine/bevy) | Game engine, ~2,500 crates |
| [zed-industries/zed](https://github.com/zed-industries/zed) | Code editor, ~460 KB Cargo.lock |

### Ruby

Bundle installs with `ruby-action`.

| Project | |
|---------|--|
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | ~150 gems |
| [discourse/discourse](https://github.com/discourse/discourse) | ~300 gems |

### Node.js

Install + build with `nodejs-action`. Turbo and pnpm caches are handled automatically.

| Project | |
|---------|--|
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | 400+ packages, Turborepo monorepo |
| [calcom/cal.com](https://github.com/calcom/cal.com) | Yarn monorepo |

## How it works

Each project has two workflows:

- **Baseline** — no cache, clean build from scratch
- **BoringCache** — uses the appropriate [BoringCache action](https://github.com/boringcache)

Both check out the same pinned commit and run identical build steps on `ubuntu-latest`. The only difference is caching.

Benchmarks run weekly and can be triggered manually:

```bash
gh workflow run "PostHog - BoringCache"
gh workflow run "Run All Benchmarks"
```

## License

MIT
