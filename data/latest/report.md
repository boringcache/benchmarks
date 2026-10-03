# Latest Benchmark Report

Generated: 2026-10-03 03:06 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 6/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 4m 4s | 3m 28s | 15% faster | n/a |
| Hugo Go | Cold Build | 1m 12s | 1m 19s | 10% slower | n/a |
| Immich | Cold Build | 5m 32s | 2m 31s | 55% faster | n/a |
| Mastodon | Warm Build | 0m 24s | 0m 15s | 38% faster | n/a |
| Mastodon Streaming | Warm Build | 0m 11s | 0m 10s | near tie | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Cold Build | 33m 9s | 13m 37s | 59% faster | n/a |
| Storybook | Cold Build | 5m 20s | 4m 34s | 14% faster | n/a |
| OpenTelemetry Java | Cold Build | 16m 29s | 15m 11s | 8% faster | n/a |
| Spring AI | Cold Build | 13m 16s | 8m 28s | 36% faster | n/a |
| gRPC | Cold Build | 53m 47s | 34m 58s | 35% faster | 528.77 MB more (338.69%) |
| Duckgres | Cold Build | 6m 30s | 4m 6s | 37% faster | n/a |
| Chroma | Warm Build | 76m 26s | 2m 27s | 97% faster | n/a |
| Linkerd2 Web | Cold Build | 4m 36s | 2m 42s | 41% faster | n/a |
| Qdrant | Cold Build | 14m 17s | 9m 36s | 33% faster | n/a |
| n8n | Cold Build | 2m 19s | 1m 41s | 27% faster | n/a |
| n8n Docker | Cold Build | 4m 59s | 3m 3s | 39% faster | n/a |
| n8n Runners | Warm Build | 1m 34s | 0m 38s | 60% faster | n/a |
| n8n Runners Distroless | Cold Build | 2m 53s | 1m 6s | 62% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
