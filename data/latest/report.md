# Latest Benchmark Report

Generated: 2026-08-11 17:57 UTC

Coverage: 18 benchmarks; fresh 18/18, rolling 17/18.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 4m 33s | 3m 48s | 16% faster | n/a |
| Hugo Go | Warm Build | 0m 10s | 0m 29s | invalid sample | n/a |
| Immich | Warm Build | 0m 24s | 0m 7s | 71% faster | n/a |
| Mastodon | Warm Build | 0m 14s | 0m 8s | 43% faster | n/a |
| Mastodon Streaming | Warm Build | 0m 14s | 0m 11s | near tie | n/a |
| PostHog | Cold Build | 38m 36s | 16m 39s | 57% faster | n/a |
| Storybook | Warm Build | 5m 27s | 5m 31s | invalid sample | n/a |
| OpenTelemetry Java | Warm Build | 2m 35s | 2m 49s | invalid sample | n/a |
| Spring AI | Warm Build | 2m 8s | 5m 16s | invalid sample | n/a |
| gRPC | Warm Build | 0m 33s | 1m 2s | invalid sample | n/a |
| Duckgres | Cold Build | 6m 30s | 3m 50s | 41% faster | n/a |
| Chroma | Warm Build | 0m 11s | 0m 7s | near tie | n/a |
| Linkerd2 Web | Warm Build | 0m 15s | 0m 7s | 53% faster | n/a |
| Qdrant | Warm Build | 0m 20s | 0m 13s | 35% faster | n/a |
| n8n | Warm Build | 0m 55s | 1m 4s | invalid sample | n/a |
| n8n Docker | Warm Build | 4m 49s | 2m 54s | 40% faster | n/a |
| n8n Runners | Warm Build | 1m 4s | 0m 41s | 36% faster | n/a |
| n8n Runners Distroless | Cold Build | 2m 22s | 1m 8s | 52% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| Immich | Commit Build | 0m 24s | 0m 11s | 54% faster | 6.90 GB less (70.56%) |
| Mastodon | Commit Build | 12m 48s | 8m 15s | investigation only | n/a |
| PostHog | Commit Build | 29m 31s | 14m 6s | 52% faster | n/a |
| Storybook | Commit Build | 3m 16s | 3m 52s | 18% slower | 1.86 GB less (57.94%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| gRPC | Commit Build | 0m 45s | 1m 0s | 33% slower | 1.74 GB more (301.6%) |
| Duckgres | Commit Build | 5m 49s | 4m 20s | 26% faster | n/a |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
| Qdrant | Commit Build | 5m 31s | 4m 8s | 25% faster | n/a |
| n8n | Commit Build | 4m 14s | 3m 55s | 7% faster | 3.69 GB less (56.93%) |
| n8n Docker | Commit Build | 5m 18s | 3m 1s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 56s | 0m 51s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 2m 14s | 1m 13s | 46% faster | n/a |
