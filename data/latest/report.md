# Latest Benchmark Report

Generated: 2026-07-20 09:45 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 24s | 1m 26s | near tie | 36.20 MB less (11.94%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 14s | 10m 57s | near tie | 49.71 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 22s | 31% faster | 176.38 MB less (18.7%) |
| gRPC | Cold Build | 38m 14s | 23m 20s | 39% faster | n/a |
| Zed | Warm Build | 19m 25s | 16m 50s | 13% faster | 2.11 GB less (78.0%) |
| n8n | Cold Build | 3m 54s | 3m 24s | 13% faster | 7.95 MB more (1.03%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 11s | 0m 8s | near tie | 119.70 MB less (25.62%) |
| Hugo Go | Commit Build | 1m 39s | 0m 50s | 49% faster | 1.01 GB less (79.5%) |
| Immich | Commit Build | 0m 11s | 0m 12s | near tie | 6.70 GB less (71.83%) |
| Mastodon | Commit Build | 4m 3s | 2m 51s | 30% faster | 8.94 GB less (89.65%) |
| Mastodon Streaming | Commit Build | 0m 27s | 0m 23s | near tie | 9.87 GB less (98.99%) |
| Discourse | Commit Build | 3m 51s | 2m 50s | 26% faster | 8.87 GB less (89.57%) |
| Discourse Base Deps | Commit Build | 0m 11s | 0m 11s | near tie | 9.20 GB less (92.91%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 16s | near tie | 8.50 GB less (85.83%) |
| Discourse Release Image | Commit Build | 0m 15s | 0m 18s | near tie | 8.40 GB less (84.83%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 8s | 47% faster | 7.95 GB less (80.31%) |
| PostHog | Commit Build | 25m 7s | 19m 36s | 22% faster | 4.68 GB less (39.69%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 18s | 1m 7s | 14% faster | 3.30 GB less (80.99%) |
| Spring AI | Commit Build | 1m 29s | 1m 23s | 7% faster | 3.23 GB less (70.48%) |
| gRPC | Commit Build | 2m 44s | 0m 39s | 76% faster | n/a |
| Zed | Commit Build | 34m 17s | 34m 31s | near tie | 10.59 GB less (92.17%) |
| n8n | Commit Build | 2m 34s | 2m 33s | near tie | 1007.17 MB less (55.49%) |
| n8n Docker | Commit Build | 5m 14s | 4m 43s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 6s | 0m 52s | 21% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 15s | 1m 43s | 24% faster | n/a |
