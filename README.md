# boringcache/benchmarks

**Cache once. Reuse everywhere.**

Real-world CI benchmarks comparing BoringCache against `actions/cache` and no-cache baselines using popular open-source projects.

## Projects

### Docker Builds

| Project | Stars | Description | Benchmark |
|---------|-------|-------------|-----------|
| [PostHog/posthog](https://github.com/PostHog/posthog) | 31k | Product analytics platform | Multi-stage Docker (Python + Node.js) |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | 50k | Decentralized social network | Multi-stage Docker (Ruby + Node.js, compiles libvips) |
| [grpc/grpc](https://github.com/grpc/grpc) | 44k | Universal RPC framework | Docker build (C++ compilation) |
| [apache/kafka](https://github.com/apache/kafka) | 32k | Distributed event streaming | Docker build (Java/Gradle) |

### Rust (Cargo + Target Cache)

| Project | Stars | Description | Benchmark |
|---------|-------|-------------|-----------|
| [zed-industries/zed](https://github.com/zed-industries/zed) | 75k | High-performance code editor | `cargo build` (~460 KB Cargo.lock) |
| [bevyengine/bevy](https://github.com/bevyengine/bevy) | 44k | Game engine | `cargo build` (~27 min CI) |

### Ruby (Bundle Cache)

| Project | Stars | Description | Benchmark |
|---------|-------|-------------|-----------|
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | 50k | Decentralized social network | `bundle install` (29 KB Gemfile.lock) |
| [discourse/discourse](https://github.com/discourse/discourse) | 46k | Community discussion platform | `bundle install` (56 KB Gemfile.lock) |

### Node.js (npm/pnpm Cache)

| Project | Stars | Description | Benchmark |
|---------|-------|-------------|-----------|
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | 174k | Workflow automation (400+ packages) | `pnpm install` monorepo |
| [calcom/cal.com](https://github.com/calcom/cal.com) | 40k | Scheduling infrastructure | Turborepo `pnpm install` + build |

## How It Works

Each project has two workflow files:

- `{project}-baseline.yml` — Uses `actions/cache` (or no cache for Docker)
- `{project}-boringcache.yml` — Uses the appropriate BoringCache action

Both workflows:
1. Check out the target repo at a **pinned commit** (reproducible)
2. Run the same build steps
3. Record step-level timing
4. Output results to workflow summary

## Running Benchmarks

Benchmarks run on a weekly schedule and can be triggered manually:

```bash
# Run a specific benchmark
gh workflow run "posthog-boringcache.yml"

# Run all benchmarks
gh workflow run "run-all.yml"
```

## Results

<!-- Results are updated automatically by the collect-results workflow -->

_Run benchmarks to populate results._

## License

MIT
