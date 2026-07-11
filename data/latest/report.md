# Latest Benchmark Report

Generated: 2026-07-11 05:34 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 22s | 4% faster | 36.28 MB less (11.96%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 29s | 10m 55s | 5% faster | 49.73 MB less (6.09%) |
| Spring AI | Warm Build | 0m 34s | 0m 27s | 21% faster | 176.12 MB less (17.96%) |
| gRPC | Cold Build | 25m 0s | 24m 40s | near tie | n/a |
| Zed | Warm Build | 20m 40s | 19m 17s | 7% faster | 2.13 GB less (78.15%) |
| n8n | Warm Build | 1m 28s | 0m 57s | 35% faster | 7.61 MB more (0.99%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 17s | 0m 7s | 59% faster | 1.59 GB less (82.4%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 0m 8s | 0m 11s | near tie | 7.27 GB less (73.33%) |
| Mastodon | Commit Build | 2m 10s | 1m 54s | 12% faster | 8.96 GB less (89.65%) |
| Mastodon Streaming | Commit Build | 0m 6s | 0m 8s | near tie | 10.31 GB less (99.03%) |
| Discourse | Commit Build | 4m 16s | 3m 9s | 26% faster | 8.82 GB less (89.55%) |
| Discourse Base Deps | Commit Build | 0m 11s | 0m 8s | near tie | 9.14 GB less (92.87%) |
| Discourse Web-Only Image | Commit Build | 0m 12s | 0m 10s | near tie | 8.53 GB less (86.63%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 10s | near tie | 8.43 GB less (85.62%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 13s | near tie | 7.90 GB less (80.25%) |
| PostHog | Commit Build | 12m 21s | 11m 16s | 9% faster | 3.29 GB less (33.77%) |
| Storybook | Commit Build | 3m 42s | 2m 51s | 23% faster | 5.21 GB less (86.09%) |
| OpenTelemetry Java | Commit Build | 9m 16s | 9m 19s | near tie | 2.81 GB less (78.74%) |
| Spring AI | Commit Build | 0m 40s | 0m 28s | 30% faster | 3.22 GB less (70.34%) |
| gRPC | Commit Build | 2m 28s | 0m 35s | 76% faster | n/a |
| Zed | Commit Build | 19m 49s | 19m 12s | 3% faster | 10.59 GB less (92.31%) |
| n8n | Commit Build | 2m 55s | 1m 54s | 35% faster | 11.86 GB less (93.86%) |
| n8n Docker | Commit Build | 5m 12s | 4m 42s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 55s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 1m 46s | 1m 38s | 8% faster | n/a |
