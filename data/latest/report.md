# Latest Benchmark Report

Generated: 2026-09-26 09:46 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 6/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 4m 9s | 3m 7s | 25% faster | n/a |
| Hugo Go | Cold Build | 1m 11s | 1m 16s | 7% slower | 619.00 MB more (401.19%) |
| Immich | Warm Build | 0m 18s | 0m 6s | 67% faster | n/a |
| Mastodon | Cold Build | 9m 54s | 8m 50s | 11% faster | n/a |
| Mastodon Streaming | Warm Build | 0m 15s | 0m 10s | near tie | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Warm Build | 0m 42s | 0m 18s | 57% faster | n/a |
| Storybook | Cold Build | 3m 46s | 6m 11s | 64% slower | n/a |
| OpenTelemetry Java | Cold Build | 12m 14s | 15m 43s | 28% slower | 582.82 KB more (1.18%) |
| Spring AI | Cold Build | 5m 47s | 8m 8s | 41% slower | 20.21 MB more (11.18%) |
| gRPC | Cold Build | 54m 17s | 32m 21s | 40% faster | 550.70 MB more (338.06%) |
| Duckgres | Cold Build | 6m 2s | 3m 38s | 40% faster | n/a |
| Chroma | Warm Build | 76m 54s | 4m 1s | 95% faster | n/a |
| Linkerd2 Web | Warm Build | 0m 19s | 0m 7s | 63% faster | n/a |
| Qdrant | Cold Build | 12m 11s | 9m 35s | 21% faster | n/a |
| n8n | Cold Build | 2m 33s | 2m 36s | near tie | 1.28 MB less (2.55%) |
| n8n Docker | Warm Build | 1m 59s | 0m 57s | 52% faster | n/a |
| n8n Runners | Cold Build | 1m 30s | 0m 43s | 52% faster | n/a |
| n8n Runners Distroless | Warm Build | 2m 23s | 1m 8s | 52% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
