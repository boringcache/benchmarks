# Latest Benchmark Report

Generated: 2026-09-05 05:22 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 7/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 37s | 0m 19s | 49% faster | n/a |
| Hugo Go | Cold Build | 1m 13s | 1m 21s | 11% slower | n/a |
| Immich | Warm Build | 0m 11s | 0m 6s | near tie | n/a |
| Mastodon | Cold Build | 10m 39s | 7m 55s | 26% faster | n/a |
| Mastodon Streaming | Cold Build | 0m 30s | 0m 21s | 30% faster | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Warm Build | 0m 36s | 0m 18s | 50% faster | n/a |
| Storybook | Warm Build | 5m 30s | 5m 31s | invalid sample | n/a |
| OpenTelemetry Java | Warm Build | 2m 42s | 16m 11s | invalid sample | n/a |
| Spring AI | Cold Build | 7m 5s | 7m 58s | 12% slower | n/a |
| gRPC | Warm Build | 1m 22s | 2m 0s | invalid sample | n/a |
| Duckgres | Cold Build | 5m 38s | 3m 59s | 29% faster | n/a |
| Chroma | Warm Build | 68m 24s | 68m 20s | near tie | n/a |
| Linkerd2 Web | Cold Build | 4m 8s | 3m 19s | 20% faster | n/a |
| Qdrant | Cold Build | 12m 32s | 9m 19s | 26% faster | n/a |
| n8n | Cold Build | 4m 3s | 4m 22s | 8% slower | n/a |
| n8n Docker | Warm Build | 2m 33s | 1m 28s | 42% faster | n/a |
| n8n Runners | Warm Build | 0m 59s | 0m 38s | 36% faster | n/a |
| n8n Runners Distroless | Warm Build | 2m 24s | 1m 6s | 54% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| Duckgres | Commit Build | 5m 49s | 4m 20s | 26% faster | n/a |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
