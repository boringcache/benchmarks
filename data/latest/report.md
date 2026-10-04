# Latest Benchmark Report

Generated: 2026-10-04 11:56 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 6/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 4m 16s | 3m 26s | 20% faster | n/a |
| Hugo Go | Cold Build | 0m 53s | 1m 18s | 47% slower | n/a |
| Immich | Cold Build | 5m 31s | 2m 36s | 53% faster | n/a |
| Mastodon | Warm Build | 0m 24s | 0m 16s | 33% faster | n/a |
| Mastodon Streaming | Cold Build | 0m 32s | 0m 25s | 22% faster | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Cold Build | 27m 37s | 14m 19s | 48% faster | n/a |
| Storybook | Cold Build | 4m 28s | 4m 30s | near tie | n/a |
| OpenTelemetry Java | Warm Build | 2m 42s | 2m 26s | 10% faster | n/a |
| Spring AI | Cold Build | 7m 39s | 7m 12s | 6% faster | n/a |
| gRPC | Cold Build | 53m 53s | 32m 35s | 40% faster | n/a |
| Duckgres | Cold Build | 6m 47s | 3m 39s | 46% faster | n/a |
| Chroma | Warm Build | 57m 10s | 2m 24s | 96% faster | n/a |
| Linkerd2 Web | Cold Build | 5m 42s | 2m 22s | 58% faster | n/a |
| Qdrant | Cold Build | 9m 22s | 10m 17s | 10% slower | n/a |
| n8n | Cold Build | 2m 23s | 2m 16s | 5% faster | n/a |
| n8n Docker | Warm Build | 1m 49s | 1m 11s | 35% faster | n/a |
| n8n Runners | Cold Build | 1m 19s | 0m 36s | 54% faster | n/a |
| n8n Runners Distroless | Cold Build | 2m 21s | 1m 11s | 50% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
