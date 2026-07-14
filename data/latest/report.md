# Latest Benchmark Report

Generated: 2026-07-14 20:57 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 10s | 18% faster | 36.28 MB less (11.96%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 29s | 10m 55s | 5% faster | 49.73 MB less (6.09%) |
| Spring AI | Warm Build | 0m 34s | 0m 27s | 21% faster | 176.12 MB less (17.96%) |
| gRPC | Cold Build | 25m 0s | 24m 40s | near tie | n/a |
| Zed | Warm Build | 20m 40s | 19m 17s | 7% faster | 2.13 GB less (78.15%) |
| n8n | Warm Build | 1m 28s | 0m 57s | 35% faster | 7.61 MB more (0.99%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 18s | 2m 27s | 26% faster | 1.18 GB less (77.73%) |
| Hugo Go | Commit Build | 1m 39s | 0m 50s | 49% faster | 1.01 GB less (79.5%) |
| Immich | Commit Build | 0m 19s | 0m 13s | 32% faster | 6.80 GB less (72.1%) |
| Mastodon | Commit Build | 2m 35s | 1m 56s | 25% faster | 8.93 GB less (89.62%) |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 8s | near tie | 10.21 GB less (99.02%) |
| Discourse | Commit Build | 3m 25s | 3m 5s | 10% faster | 8.80 GB less (89.51%) |
| Discourse Base Deps | Commit Build | 0m 11s | 0m 12s | near tie | 9.13 GB less (92.86%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 12s | near tie | 8.52 GB less (86.58%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 10s | near tie | 8.42 GB less (85.57%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 15s | 67% slower | 7.89 GB less (80.19%) |
| PostHog | Commit Build | 21m 26s | 19m 47s | 8% faster | 2.94 GB less (29.57%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 44s | 1m 3s | 39% faster | 3.14 GB less (80.5%) |
| Spring AI | Commit Build | 3m 30s | 3m 33s | near tie | 3.22 GB less (70.39%) |
| gRPC | Commit Build | 2m 12s | 1m 26s | 35% faster | n/a |
| Zed | Commit Build | 26m 14s | 25m 24s | 3% faster | 10.58 GB less (92.31%) |
| n8n | Commit Build | 4m 36s | 3m 52s | 16% faster | 13.26 GB less (94.46%) |
| n8n Docker | Commit Build | 5m 19s | 5m 50s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 45s | 0m 48s | 54% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 51s | 1m 53s | 34% faster | n/a |
