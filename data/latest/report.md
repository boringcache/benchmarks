# Latest Benchmark Report

Generated: 2026-10-04 03:26 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 6/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 30s | 0m 17s | 43% faster | n/a |
| Hugo Go | Cold Build | 1m 7s | 1m 3s | 6% faster | n/a |
| Immich | Warm Build | 0m 19s | 0m 9s | 53% faster | n/a |
| Mastodon | Warm Build | 0m 14s | 0m 9s | near tie | n/a |
| Mastodon Streaming | Cold Build | 0m 31s | 0m 21s | 32% faster | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Cold Build | 25m 22s | 14m 34s | 43% faster | n/a |
| Storybook | Warm Build | 4m 33s | 4m 10s | 8% faster | n/a |
| OpenTelemetry Java | Cold Build | 14m 44s | 14m 50s | near tie | n/a |
| Spring AI | Cold Build | 7m 40s | 7m 21s | 4% faster | n/a |
| gRPC | Cold Build | 35m 44s | 35m 45s | near tie | n/a |
| Duckgres | Cold Build | 5m 41s | 3m 54s | 31% faster | n/a |
| Chroma | Warm Build | 67m 14s | 2m 20s | 97% faster | n/a |
| Linkerd2 Web | Warm Build | 0m 13s | 0m 6s | 54% faster | n/a |
| Qdrant | Warm Build | 0m 24s | 0m 16s | 33% faster | n/a |
| n8n | Cold Build | 1m 35s | 2m 14s | 41% slower | 1.25 MB less (2.48%) |
| n8n Docker | Warm Build | 2m 28s | 0m 55s | 63% faster | n/a |
| n8n Runners | Cold Build | 1m 29s | 0m 43s | 52% faster | n/a |
| n8n Runners Distroless | Warm Build | 2m 16s | 1m 10s | 49% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
