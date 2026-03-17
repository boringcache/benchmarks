# BoringCache Benchmarks

This repo is the central aggregator for BoringCache benchmark data.

It does not own benchmark source trees, Dockerfiles, or benchmark execution for the
individual projects. Those live in standalone benchmark repos:

- `boringcache/benchmark-hugo`
- `boringcache/benchmark-immich`
- `boringcache/benchmark-mastodon`
- `boringcache/benchmark-posthog`
- `boringcache/benchmark-opentelemetry-java`
- `boringcache/benchmark-spring-ai`
- `boringcache/benchmark-grpc`
- `boringcache/benchmark-zed`
- `boringcache/benchmark-n8n`

Each benchmark repo:

- pins upstream source under `upstream/`
- owns its own AC/BC workflows
- runs on its own nightly schedule
- publishes JSON benchmark artifacts

This repo:

- fetches the latest successful benchmark artifacts from those standalone repos
- rebuilds `data/latest/index.json`
- serves as the central website/index feed

## Local Usage

Regenerate the latest index locally:

```bash
ruby scripts/publish-index.rb
```

The script expects GitHub CLI authentication that can read workflow runs and artifacts
from the standalone benchmark repos.
