# Latest Benchmark Report

Generated: 2026-07-07 21:10 UTC

Coverage: 20 benchmarks; fresh 5/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 31s | 3m 36s | near tie | 48.52 MB more (6.19%) |
| OpenTelemetry Java | Warm Build | 1m 1s | 0m 59s | 3% faster | 49.63 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 23s | 28% faster | 177.03 MB less (17.99%) |
| gRPC | Cold Build | 32m 56s | 23m 35s | 28% faster | n/a |
| n8n | Cold Build | 5m 41s | 5m 47s | near tie | 9.61 MB more (1.32%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 49s | 2m 44s | near tie | 1.60 GB less (82.52%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 0m 10s | 0m 9s | near tie | 7.76 GB less (74.62%) |
| Mastodon | Commit Build | 0m 16s | 0m 16s | near tie | 9.25 GB less (90.02%) |
| Mastodon Streaming | Commit Build | 0m 12s | 0m 9s | near tie | 9.89 GB less (98.99%) |
| Discourse | Commit Build | 3m 16s | 3m 10s | 3% faster | 8.78 GB less (89.52%) |
| Discourse Base Deps | Commit Build | 0m 21s | 0m 9s | 57% faster | 9.30 GB less (92.98%) |
| Discourse Web-Only Image | Commit Build | 0m 22s | 0m 11s | 50% faster | 8.68 GB less (86.85%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 11s | near tie | 8.58 GB less (85.86%) |
| Discourse Test Image | Commit Build | 0m 11s | 0m 13s | near tie | 8.06 GB less (80.57%) |
| PostHog | Commit Build | 14m 37s | 11m 50s | 19% faster | 2.67 GB less (28.0%) |
| Storybook | Commit Build | 4m 8s | 3m 28s | 16% faster | 4.74 GB less (85.3%) |
| OpenTelemetry Java | Commit Build | 9m 8s | 12m 1s | 32% slower | 3.23 GB less (81.17%) |
| Spring AI | Commit Build | 3m 33s | 3m 22s | 5% faster | 3.20 GB less (70.43%) |
| gRPC | Commit Build | 6m 19s | 4m 51s | 23% faster | n/a |
| Zed | Commit Build | 25m 14s | 25m 23s | near tie | 10.55 GB less (92.3%) |
| n8n | Commit Build | 3m 10s | 2m 28s | 22% faster | 10.47 GB less (93.43%) |
| n8n Docker | Commit Build | 6m 39s | 4m 54s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 21s | 0m 51s | 37% faster | n/a |
| n8n Runners Distroless | Commit Build | 3m 5s | 1m 34s | 49% faster | n/a |
