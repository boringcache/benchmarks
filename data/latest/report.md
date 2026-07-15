# Latest Benchmark Report

Generated: 2026-07-15 05:26 UTC

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
| Immich | Commit Build | 0m 10s | 0m 11s | near tie | 6.87 GB less (72.22%) |
| Mastodon | Commit Build | 2m 35s | 1m 56s | 25% faster | 8.93 GB less (89.62%) |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 8s | near tie | 10.21 GB less (99.02%) |
| Discourse | Commit Build | 4m 23s | 3m 5s | 30% faster | 8.85 GB less (89.56%) |
| Discourse Base Deps | Commit Build | 0m 12s | 0m 14s | near tie | 9.28 GB less (92.97%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 17s | near tie | 8.66 GB less (86.78%) |
| Discourse Release Image | Commit Build | 0m 7s | 0m 12s | near tie | 8.57 GB less (85.79%) |
| Discourse Test Image | Commit Build | 0m 17s | 0m 8s | 53% faster | 8.04 GB less (80.49%) |
| PostHog | Commit Build | 26m 55s | 22m 9s | 18% faster | 4.95 GB less (41.39%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 44s | 1m 3s | 39% faster | 3.14 GB less (80.5%) |
| Spring AI | Commit Build | 3m 30s | 3m 33s | near tie | 3.22 GB less (70.39%) |
| gRPC | Commit Build | 3m 4s | 0m 34s | 82% faster | n/a |
| Zed | Commit Build | 39m 5s | 44m 12s | 13% slower | 10.56 GB less (92.29%) |
| n8n | Commit Build | 7m 0s | 3m 49s | 45% faster | 13.34 GB less (94.49%) |
| n8n Docker | Commit Build | 6m 13s | 4m 41s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 10s | 0m 55s | 21% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 25s | 1m 35s | 34% faster | n/a |
