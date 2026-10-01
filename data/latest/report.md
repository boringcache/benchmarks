# Latest Benchmark Report

Generated: 2026-10-01 02:48 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 6/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 31s | 0m 22s | 29% faster | n/a |
| Hugo Go | Cold Build | 1m 9s | 1m 25s | 23% slower | 619.92 MB more (401.96%) |
| Immich | Cold Build | 5m 42s | 2m 23s | 58% faster | n/a |
| Mastodon | Cold Build | 9m 56s | 7m 50s | 21% faster | n/a |
| Mastodon Streaming | Cold Build | 0m 21s | 0m 21s | near tie | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Cold Build | 34m 17s | 16m 45s | 51% faster | n/a |
| Storybook | Cold Build | 4m 15s | 4m 44s | 11% slower | n/a |
| OpenTelemetry Java | Cold Build | 16m 16s | 11m 6s | 32% faster | 507.00 KB more (1.02%) |
| Spring AI | Cold Build | 8m 55s | 8m 9s | 9% faster | 20.39 MB more (11.29%) |
| gRPC | Warm Build | 1m 50s | 1m 45s | 5% faster | 527.74 MB more (338.66%) |
| Duckgres | Cold Build | 6m 9s | 3m 13s | 48% faster | n/a |
| Chroma | Warm Build | 54m 45s | 2m 21s | 96% faster | n/a |
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
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
