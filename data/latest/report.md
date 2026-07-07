# Latest Benchmark Report

Generated: 2026-07-07 09:52 UTC

Coverage: 20 benchmarks; fresh 6/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 31s | 3m 36s | near tie | 48.52 MB more (6.19%) |
| OpenTelemetry Java | Warm Build | 1m 1s | 0m 59s | 3% faster | 49.63 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 23s | 28% faster | 177.03 MB less (17.99%) |
| gRPC | Cold Build | 32m 56s | 23m 35s | 28% faster | n/a |
| Zed | Cold Build | 54m 28s | 52m 9s | 4% faster | 2.11 GB less (75.65%) |
| n8n | Cold Build | 5m 41s | 5m 47s | near tie | 9.61 MB more (1.32%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 49s | 2m 44s | near tie | 1.60 GB less (82.52%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 5m 14s | 3m 11s | 39% faster | 7.28 GB less (73.4%) |
| Mastodon | Commit Build | 0m 16s | 0m 16s | near tie | 9.25 GB less (90.02%) |
| Mastodon Streaming | Commit Build | 0m 12s | 0m 9s | near tie | 9.89 GB less (98.99%) |
| Discourse | Commit Build | 4m 3s | 3m 9s | 22% faster | 8.55 GB less (89.27%) |
| Discourse Base Deps | Commit Build | 0m 11s | 0m 13s | near tie | 8.87 GB less (92.67%) |
| Discourse Web-Only Image | Commit Build | 0m 11s | 0m 10s | near tie | 8.26 GB less (86.27%) |
| Discourse Release Image | Commit Build | 0m 14s | 0m 11s | near tie | 8.16 GB less (85.24%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 9s | near tie | 7.63 GB less (79.72%) |
| PostHog | Commit Build | 14m 37s | 12m 22s | 15% faster | 2.90 GB less (29.76%) |
| Storybook | Commit Build | 3m 46s | 3m 19s | 12% faster | 4.31 GB less (80.93%) |
| OpenTelemetry Java | Commit Build | 9m 8s | 12m 1s | 32% slower | 3.23 GB less (81.17%) |
| Spring AI | Commit Build | 1m 11s | 3m 23s | 186% slower | 3.20 GB less (70.43%) |
| gRPC | Commit Build | 1m 26s | 0m 38s | 56% faster | n/a |
| Zed | Commit Build | 39m 19s | 38m 46s | near tie | 10.51 GB less (92.28%) |
| n8n | Commit Build | 7m 16s | 5m 25s | 25% faster | 9.99 GB less (93.14%) |
| n8n Docker | Commit Build | 6m 17s | 4m 54s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 13s | 0m 55s | 25% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 41s | 1m 34s | 7% faster | n/a |
