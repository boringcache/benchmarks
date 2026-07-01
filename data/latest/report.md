# Latest Benchmark Report

Generated: 2026-07-01 13:36 UTC

Coverage: 20 benchmarks; fresh 6/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 31s | 3m 36s | near tie | 48.52 MB more (6.19%) |
| OpenTelemetry Java | Warm Build | 1m 12s | 0m 58s | 19% faster | 49.62 MB less (6.08%) |
| Spring AI | Warm Build | 0m 31s | 0m 27s | near tie | 178.93 MB less (17.92%) |
| gRPC | Cold Build | 32m 51s | 22m 36s | 31% faster | n/a |
| Zed | Cold Build | 54m 28s | 52m 9s | 4% faster | 2.11 GB less (75.65%) |
| n8n | Cold Build | 5m 18s | 5m 34s | 5% slower | 10.17 MB more (1.4%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 7s | 3m 33s | cache import unavailable | 815.05 MB less (70.09%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 3m 37s | 3m 4s | 15% faster | 6.69 GB less (71.75%) |
| Mastodon | Commit Build | 2m 40s | 1m 50s | 31% faster | 8.90 GB less (89.69%) |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 14s | near tie | 9.82 GB less (98.98%) |
| Discourse | Commit Build | 4m 9s | 2m 57s | 29% faster | 8.90 GB less (89.65%) |
| Discourse Base Deps | Commit Build | 0m 18s | 0m 8s | 56% faster | 9.20 GB less (92.91%) |
| Discourse Web-Only Image | Commit Build | 0m 17s | 0m 11s | 35% faster | 8.58 GB less (86.72%) |
| Discourse Release Image | Commit Build | 0m 11s | 0m 9s | near tie | 8.49 GB less (85.72%) |
| Discourse Test Image | Commit Build | 0m 10s | 0m 14s | near tie | 7.96 GB less (80.36%) |
| PostHog | Commit Build | 13m 50s | 11m 51s | 14% faster | 3.18 GB less (32.33%) |
| Storybook | Commit Build | 1m 27s | 1m 39s | 14% slower | 3.98 GB less (79.98%) |
| OpenTelemetry Java | Commit Build | 11m 10s | 7m 28s | 33% faster | 1.86 GB less (52.79%) |
| Spring AI | Commit Build | 1m 21s | 1m 6s | 19% faster | 3.18 GB less (70.55%) |
| gRPC | Commit Build | 4m 40s | 3m 7s | 33% faster | n/a |
| Zed | Commit Build | 35m 27s | 41m 31s | 17% slower | 10.55 GB less (92.52%) |
| n8n | Commit Build | 4m 58s | 5m 7s | 3% slower | 7.82 GB less (91.42%) |
| n8n Docker | Commit Build | 4m 25s | 4m 51s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 58s | 0m 56s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 1m 55s | 1m 39s | 14% faster | n/a |
