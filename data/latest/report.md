# Latest Benchmark Report

Generated: 2026-07-15 17:04 UTC

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
| Immich | Commit Build | 0m 8s | 7m 44s | cache import unavailable | 7.21 GB less (73.19%) |
| Mastodon | Commit Build | 2m 7s | 1m 56s | 9% faster | 8.95 GB less (89.64%) |
| Mastodon Streaming | Commit Build | 0m 9s | 0m 10s | near tie | 9.89 GB less (98.99%) |
| Discourse | Commit Build | 3m 11s | 3m 25s | 7% slower | 8.96 GB less (89.67%) |
| Discourse Base Deps | Commit Build | 0m 15s | 0m 14s | near tie | 9.20 GB less (92.91%) |
| Discourse Web-Only Image | Commit Build | 0m 10s | 0m 9s | near tie | 9.02 GB less (87.23%) |
| Discourse Release Image | Commit Build | 0m 12s | 0m 12s | near tie | 8.48 GB less (85.67%) |
| Discourse Test Image | Commit Build | 0m 11s | 0m 12s | near tie | 7.95 GB less (80.32%) |
| PostHog | Commit Build | 24m 38s | 19m 12s | 22% faster | 3.43 GB less (32.81%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 44s | 1m 3s | 39% faster | 3.14 GB less (80.5%) |
| Spring AI | Commit Build | 1m 1s | 0m 27s | 56% faster | 3.22 GB less (70.36%) |
| gRPC | Commit Build | 2m 49s | 0m 39s | 77% faster | n/a |
| Zed | Commit Build | 46m 33s | 42m 48s | 8% faster | 10.58 GB less (92.31%) |
| n8n | Commit Build | 4m 24s | 3m 17s | 25% faster | 14.02 GB less (94.74%) |
| n8n Docker | Commit Build | 5m 3s | 5m 26s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 7s | 0m 54s | 19% faster | n/a |
| n8n Runners Distroless | Commit Build | 3m 11s | 1m 51s | cache import unavailable | n/a |
