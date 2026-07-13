# Latest Benchmark Report

Generated: 2026-07-13 09:52 UTC

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
| Hugo | Commit Build | 0m 13s | 0m 13s | near tie | 1.18 GB less (77.73%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 0m 8s | 0m 11s | near tie | 7.27 GB less (73.33%) |
| Mastodon | Commit Build | 2m 4s | 3m 2s | 47% slower | 8.95 GB less (89.65%) |
| Mastodon Streaming | Commit Build | 0m 19s | 0m 22s | near tie | 10.22 GB less (99.02%) |
| Discourse | Commit Build | 3m 20s | 3m 42s | 11% slower | 8.83 GB less (89.55%) |
| Discourse Base Deps | Commit Build | 0m 10s | 0m 13s | near tie | 9.51 GB less (93.12%) |
| Discourse Web-Only Image | Commit Build | 0m 18s | 0m 9s | 50% faster | 8.89 GB less (87.1%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 9s | near tie | 8.79 GB less (86.12%) |
| Discourse Test Image | Commit Build | 0m 10s | 0m 12s | near tie | 8.26 GB less (80.94%) |
| PostHog | Commit Build | 20m 9s | 13m 8s | 35% faster | 3.54 GB less (35.45%) |
| Storybook | Commit Build | 1m 20s | 0m 46s | 43% faster | 5.22 GB less (86.12%) |
| OpenTelemetry Java | Commit Build | 9m 16s | 9m 19s | near tie | 2.81 GB less (78.74%) |
| Spring AI | Commit Build | 1m 23s | 1m 27s | 5% slower | 3.22 GB less (70.34%) |
| gRPC | Commit Build | 15m 23s | 10m 42s | 30% faster | n/a |
| Zed | Commit Build | 42m 41s | 35m 55s | 16% faster | 10.57 GB less (92.3%) |
| n8n | Commit Build | 4m 7s | 3m 34s | 13% faster | 12.04 GB less (93.95%) |
| n8n Docker | Commit Build | 5m 13s | 5m 48s | 11% slower | n/a |
| n8n Runners | Commit Build | 1m 18s | 0m 55s | 29% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 53s | 1m 27s | 50% faster | n/a |
