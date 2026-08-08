# Latest Benchmark Report

Generated: 2026-08-08 09:19 UTC

Coverage: 22 benchmarks; fresh 14/22, rolling 22/22.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 26s | 2m 44s | 20% faster | n/a |
| Hugo Go | Cold Build | 1m 27s | 1m 35s | 9% slower | 159.21 MB less (52.43%) |
| Immich | Cold Build | 7m 14s | 6m 2s | 17% faster | n/a |
| Mastodon | Cold Build | 11m 25s | 8m 42s | 24% faster | n/a |
| Discourse | Cold Build | 6m 14s | 4m 38s | 26% faster | n/a |
| PostHog | Cold Build | 30m 31s | 15m 44s | 48% faster | 4.70 GB less (41.4%) |
| Storybook | Cold Build | 4m 43s | 4m 6s | 13% faster | 19.21 MB less (1.43%) |
| OpenTelemetry Java | Cold Build | 11m 42s | 11m 29s | near tie | 2.71 MB less (0.32%) |
| Spring AI | Cold Build | 5m 14s | 4m 25s | 16% faster | 5.16 MB more (0.55%) |
| gRPC | Warm Build | 0m 33s | 1m 2s | invalid sample | n/a |
| n8n | Warm Build | 0m 53s | 1m 1s | invalid sample | n/a |
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
| Discourse | Commit Build | 4m 9s | 3m 19s | 20% faster | 8.87 GB less (89.57%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 9s | near tie | 9.20 GB less (92.91%) |
| Discourse Web-Only Image | Commit Build | 0m 10s | 0m 8s | near tie | 8.58 GB less (86.66%) |
| Discourse Release Image | Commit Build | 0m 18s | 0m 9s | 50% faster | 8.48 GB less (85.65%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 9s | near tie | 7.95 GB less (80.29%) |
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
