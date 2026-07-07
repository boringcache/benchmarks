# Latest Benchmark Report

Generated: 2026-07-07 01:17 UTC

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
| Immich | Commit Build | 0m 19s | 0m 10s | 47% faster | 7.28 GB less (73.42%) |
| Mastodon | Commit Build | 2m 50s | 1m 48s | 36% faster | 8.94 GB less (89.7%) |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 10s | near tie | 10.22 GB less (99.02%) |
| Discourse | Commit Build | 3m 9s | 3m 6s | near tie | 8.93 GB less (89.68%) |
| Discourse Base Deps | Commit Build | 0m 18s | 0m 11s | 39% faster | 9.26 GB less (92.95%) |
| Discourse Web-Only Image | Commit Build | 0m 14s | 0m 11s | near tie | 8.65 GB less (86.8%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 9s | near tie | 8.55 GB less (85.81%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 12s | near tie | 8.02 GB less (80.5%) |
| PostHog | Commit Build | 15m 33s | 11m 43s | 25% faster | 3.08 GB less (31.02%) |
| Storybook | Commit Build | 3m 46s | 3m 19s | 12% faster | 4.31 GB less (80.93%) |
| OpenTelemetry Java | Commit Build | 9m 8s | 12m 1s | 32% slower | 3.23 GB less (81.17%) |
| Spring AI | Commit Build | 1m 38s | 1m 24s | 14% faster | 3.19 GB less (70.56%) |
| gRPC | Commit Build | 5m 41s | 3m 39s | 36% faster | n/a |
| Zed | Commit Build | 42m 48s | 42m 53s | near tie | 10.51 GB less (92.43%) |
| n8n | Commit Build | 3m 51s | 3m 11s | 17% faster | 9.88 GB less (93.07%) |
| n8n Docker | Commit Build | 5m 41s | 4m 46s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 8s | 0m 56s | 18% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 17s | 1m 34s | 31% faster | n/a |
