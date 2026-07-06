# Latest Benchmark Report

Generated: 2026-07-06 21:19 UTC

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
| Immich | Commit Build | 6m 31s | 5m 23s | 17% faster | 6.98 GB less (72.6%) |
| Mastodon | Commit Build | 2m 50s | 1m 48s | 36% faster | 8.94 GB less (89.7%) |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 10s | near tie | 10.22 GB less (99.02%) |
| Discourse | Commit Build | 3m 16s | 3m 9s | 4% faster | 8.93 GB less (89.67%) |
| Discourse Base Deps | Commit Build | 0m 15s | 0m 11s | near tie | 9.53 GB less (93.14%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 10s | near tie | 8.92 GB less (87.15%) |
| Discourse Release Image | Commit Build | 0m 20s | 0m 10s | 50% faster | 8.82 GB less (86.18%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 10s | near tie | 8.29 GB less (81.02%) |
| PostHog | Commit Build | 24m 30s | 14m 26s | 41% faster | 4.68 GB less (40.64%) |
| Storybook | Commit Build | 3m 46s | 3m 19s | 12% faster | 4.31 GB less (80.93%) |
| OpenTelemetry Java | Commit Build | 9m 8s | 12m 1s | 32% slower | 3.23 GB less (81.17%) |
| Spring AI | Commit Build | 1m 38s | 1m 24s | 14% faster | 3.19 GB less (70.56%) |
| gRPC | Commit Build | 1m 32s | 0m 36s | 61% faster | n/a |
| Zed | Commit Build | 25m 2s | 25m 14s | near tie | 10.54 GB less (92.45%) |
| n8n | Commit Build | 3m 51s | 3m 11s | 17% faster | 9.88 GB less (93.07%) |
| n8n Docker | Commit Build | 5m 41s | 4m 46s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 8s | 0m 56s | 18% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 17s | 1m 34s | 31% faster | n/a |
