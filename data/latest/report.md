# Latest Benchmark Report

Generated: 2026-07-13 17:24 UTC

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
| Immich | Commit Build | 4m 24s | 3m 9s | 28% faster | 7.28 GB less (73.37%) |
| Mastodon | Commit Build | 3m 34s | 2m 56s | 18% faster | 8.95 GB less (89.65%) |
| Mastodon Streaming | Commit Build | 0m 9s | 0m 21s | 133% slower | 9.88 GB less (98.99%) |
| Discourse | Commit Build | 3m 57s | 3m 7s | 21% faster | 8.71 GB less (89.42%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 14s | 75% slower | 9.39 GB less (93.04%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 11s | near tie | 8.77 GB less (86.94%) |
| Discourse Release Image | Commit Build | 0m 24s | 0m 16s | 33% faster | 8.40 GB less (85.57%) |
| Discourse Test Image | Commit Build | 0m 10s | 0m 12s | near tie | 7.87 GB less (80.18%) |
| PostHog | Commit Build | 19m 42s | 18m 47s | 5% faster | 3.02 GB less (30.36%) |
| Storybook | Commit Build | 3m 52s | 3m 27s | 11% faster | 5.34 GB less (85.86%) |
| OpenTelemetry Java | Commit Build | 1m 21s | 1m 7s | 17% faster | 2.77 GB less (78.52%) |
| Spring AI | Commit Build | 1m 23s | 1m 27s | 5% slower | 3.22 GB less (70.34%) |
| gRPC | Commit Build | 8m 24s | 4m 43s | 44% faster | n/a |
| Zed | Commit Build | 40m 8s | 38m 14s | 5% faster | 10.51 GB less (92.26%) |
| n8n | Commit Build | 5m 57s | 4m 0s | 33% faster | 12.40 GB less (94.12%) |
| n8n Docker | Commit Build | 6m 10s | 5m 24s | 12% faster | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 51s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 2m 10s | 1m 37s | 25% faster | n/a |
