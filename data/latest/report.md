# Latest Benchmark Report

Generated: 2026-07-07 13:24 UTC

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
| Immich | Commit Build | 7m 3s | 3m 49s | 46% faster | 7.38 GB less (73.64%) |
| Mastodon | Commit Build | 0m 16s | 0m 16s | near tie | 9.25 GB less (90.02%) |
| Mastodon Streaming | Commit Build | 0m 12s | 0m 9s | near tie | 9.89 GB less (98.99%) |
| Discourse | Commit Build | 3m 13s | 3m 2s | 6% faster | 8.90 GB less (89.64%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 11s | near tie | 9.13 GB less (92.86%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 11s | near tie | 8.52 GB less (86.64%) |
| Discourse Release Image | Commit Build | 0m 11s | 0m 16s | near tie | 8.42 GB less (85.63%) |
| Discourse Test Image | Commit Build | 0m 10s | 0m 9s | near tie | 7.89 GB less (80.25%) |
| PostHog | Commit Build | 24m 4s | 11m 46s | 51% faster | 4.05 GB less (37.22%) |
| Storybook | Commit Build | 4m 10s | 3m 19s | 20% faster | 4.59 GB less (84.91%) |
| OpenTelemetry Java | Commit Build | 9m 8s | 12m 1s | 32% slower | 3.23 GB less (81.17%) |
| Spring AI | Commit Build | 1m 2s | 0m 30s | 52% faster | 3.20 GB less (70.43%) |
| gRPC | Commit Build | 1m 26s | 0m 38s | 56% faster | n/a |
| Zed | Commit Build | 41m 56s | 41m 8s | near tie | 10.58 GB less (92.32%) |
| n8n | Commit Build | 5m 37s | 4m 40s | 17% faster | 10.15 GB less (93.24%) |
| n8n Docker | Commit Build | 6m 17s | 4m 54s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 13s | 0m 55s | 25% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 41s | 1m 34s | 7% faster | n/a |
