# Latest Benchmark Report

Generated: 2026-10-05 08:36 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 11/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 22s | 0m 18s | near tie | n/a |
| Hugo Go | Cold Build | 1m 11s | 1m 17s | 8% slower | 619.85 MB more (401.73%) |
| Immich | Cold Build | 4m 2s | 2m 24s | 40% faster | n/a |
| Mastodon | Cold Build | 11m 53s | 8m 26s | 29% faster | n/a |
| Mastodon Streaming | Cold Build | 0m 27s | 0m 25s | near tie | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Cold Build | 34m 13s | 14m 8s | 59% faster | n/a |
| Storybook | Cold Build | 3m 44s | 4m 39s | 25% slower | n/a |
| OpenTelemetry Java | Cold Build | 10m 0s | 15m 25s | 54% slower | n/a |
| Spring AI | Cold Build | 6m 13s | 8m 38s | 39% slower | 20.28 MB more (11.22%) |
| gRPC | Cold Build | 27m 24s | 34m 19s | 25% slower | n/a |
| Duckgres | Cold Build | 6m 45s | 3m 8s | 54% faster | n/a |
| Chroma | Warm Build | 60m 22s | 2m 28s | 96% faster | n/a |
| Linkerd2 Web | Cold Build | 5m 7s | 3m 13s | 37% faster | n/a |
| Qdrant | Cold Build | 11m 2s | 10m 5s | 9% faster | n/a |
| n8n | Cold Build | 2m 23s | 2m 19s | near tie | n/a |
| n8n Docker | Warm Build | 1m 54s | 1m 6s | 42% faster | n/a |
| n8n Runners | Warm Build | 16m 58s | 0m 35s | 97% faster | n/a |
| n8n Runners Distroless | Cold Build | 3m 0s | 1m 6s | 63% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| gRPC | Commit Build | 2m 21s | 0m 40s | 72% faster | n/a |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
| n8n | Commit Build | 1m 16s | 1m 18s | near tie | 1.74 GB less (38.72%) |
| n8n Docker | Commit Build | 4m 14s | 3m 2s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 40s | 26% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 52s | 1m 48s | 4% faster | n/a |
