# Latest Benchmark Report

Generated: 2026-09-30 19:58 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 6/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 27s | 0m 20s | 26% faster | n/a |
| Hugo Go | Cold Build | 1m 9s | 1m 25s | 23% slower | 619.92 MB more (401.96%) |
| Immich | Warm Build | 0m 20s | 0m 10s | 50% faster | n/a |
| Mastodon | Cold Build | 10m 29s | 6m 45s | 36% faster | n/a |
| Mastodon Streaming | Warm Build | 0m 16s | 0m 10s | 38% faster | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Cold Build | 50m 1s | 14m 43s | 71% faster | n/a |
| Storybook | Cold Build | 4m 15s | 4m 44s | 11% slower | n/a |
| OpenTelemetry Java | Cold Build | 12m 14s | 15m 43s | 28% slower | 582.82 KB more (1.18%) |
| Spring AI | Cold Build | 6m 13s | 8m 38s | 39% slower | 20.28 MB more (11.22%) |
| gRPC | Cold Build | 54m 17s | 32m 21s | 40% faster | 550.70 MB more (338.06%) |
| Duckgres | Cold Build | 6m 9s | 3m 13s | 48% faster | n/a |
| Chroma | Warm Build | 80m 19s | 2m 26s | 97% faster | n/a |
| Linkerd2 Web | Cold Build | 4m 31s | 3m 15s | 28% faster | n/a |
| Qdrant | Warm Build | 0m 15s | 0m 11s | near tie | n/a |
| n8n | Cold Build | 2m 17s | 2m 1s | 12% faster | 1.27 MB less (2.52%) |
| n8n Docker | Warm Build | 2m 26s | 1m 19s | 46% faster | n/a |
| n8n Runners | Cold Build | 1m 20s | 0m 44s | 45% faster | n/a |
| n8n Runners Distroless | Warm Build | 2m 41s | 1m 6s | 59% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 1m 39s | 0m 50s | 49% faster | 1.01 GB less (79.5%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
