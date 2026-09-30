# Latest Benchmark Report

Generated: 2026-09-30 10:03 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 9/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 27s | 0m 20s | 26% faster | n/a |
| Hugo Go | Cold Build | 1m 11s | 0m 57s | 20% faster | 619.48 MB more (401.57%) |
| Immich | Warm Build | 0m 20s | 0m 10s | 50% faster | n/a |
| Mastodon | Cold Build | 10m 29s | 6m 45s | 36% faster | n/a |
| Mastodon Streaming | Warm Build | 0m 16s | 0m 10s | 38% faster | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Cold Build | 29m 35s | 13m 30s | 54% faster | n/a |
| Storybook | Cold Build | 4m 52s | 4m 23s | 10% faster | n/a |
| OpenTelemetry Java | Cold Build | 12m 14s | 15m 43s | 28% slower | 582.82 KB more (1.18%) |
| Spring AI | Cold Build | 6m 13s | 8m 38s | 39% slower | 20.28 MB more (11.22%) |
| gRPC | Cold Build | 54m 17s | 32m 21s | 40% faster | 550.70 MB more (338.06%) |
| Duckgres | Cold Build | 7m 28s | 4m 10s | 44% faster | n/a |
| Chroma | Warm Build | 80m 19s | 2m 26s | 97% faster | n/a |
| Linkerd2 Web | Cold Build | 4m 53s | 3m 15s | 33% faster | n/a |
| Qdrant | Warm Build | 0m 29s | 0m 18s | 38% faster | n/a |
| n8n | Cold Build | 2m 33s | 2m 36s | near tie | 1.28 MB less (2.55%) |
| n8n Docker | Warm Build | 1m 59s | 0m 57s | 52% faster | n/a |
| n8n Runners | Cold Build | 1m 30s | 0m 43s | 52% faster | n/a |
| n8n Runners Distroless | Warm Build | 2m 23s | 1m 8s | 52% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| Immich | Commit Build | 0m 17s | 0m 7s | 59% faster | 6.74 GB less (70.05%) |
| Mastodon | Commit Build | 2m 4s | 1m 55s | 7% faster | 8.95 GB less (89.72%) |
| Storybook | Commit Build | 3m 16s | 3m 52s | 18% slower | 1.86 GB less (57.94%) |
| OpenTelemetry Java | Commit Build | 1m 23s | 1m 4s | 23% faster | 3.24 GB less (80.68%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
