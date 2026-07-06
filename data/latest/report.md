# Latest Benchmark Report

Generated: 2026-07-06 17:31 UTC

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
| Hugo | Commit Build | 2m 50s | 2m 59s | 5% slower | 1.52 GB less (81.79%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 4m 18s | 3m 9s | 27% faster | 7.30 GB less (73.57%) |
| Mastodon | Commit Build | 2m 50s | 1m 48s | 36% faster | 8.94 GB less (89.7%) |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 10s | near tie | 10.22 GB less (99.02%) |
| Discourse | Commit Build | 3m 58s | 3m 8s | 21% faster | 8.92 GB less (89.67%) |
| Discourse Base Deps | Commit Build | 0m 19s | 0m 12s | 37% faster | 9.59 GB less (93.18%) |
| Discourse Web-Only Image | Commit Build | 0m 10s | 0m 11s | near tie | 8.98 GB less (87.23%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 12s | near tie | 8.88 GB less (86.27%) |
| Discourse Test Image | Commit Build | 0m 16s | 0m 9s | 44% faster | 8.35 GB less (81.13%) |
| PostHog | Commit Build | 20m 47s | 13m 6s | 37% faster | 4.10 GB less (37.42%) |
| Storybook | Commit Build | 3m 46s | 3m 19s | 12% faster | 4.31 GB less (80.93%) |
| OpenTelemetry Java | Commit Build | 9m 8s | 12m 1s | 32% slower | 3.23 GB less (81.17%) |
| Spring AI | Commit Build | 1m 38s | 1m 24s | 14% faster | 3.19 GB less (70.56%) |
| gRPC | Commit Build | 1m 32s | 0m 36s | 61% faster | n/a |
| Zed | Commit Build | 38m 51s | 32m 3s | 18% faster | 10.53 GB less (92.44%) |
| n8n | Commit Build | 5m 43s | 3m 40s | 36% faster | 9.71 GB less (92.96%) |
| n8n Docker | Commit Build | 5m 45s | 5m 18s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 58s | 0m 52s | 10% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 27s | 1m 41s | 31% faster | n/a |
