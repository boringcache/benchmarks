# Latest Benchmark Report

Generated: 2026-07-01 21:13 UTC

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
| Mastodon | Commit Build | 2m 6s | 3m 45s | 79% slower | 8.86 GB less (89.65%) |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 13s | 86% slower | 10.30 GB less (99.03%) |
| Discourse | Commit Build | 3m 35s | 3m 10s | 12% faster | 8.84 GB less (89.59%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 7s | near tie | 9.16 GB less (92.88%) |
| Discourse Web-Only Image | Commit Build | 0m 11s | 0m 18s | 64% slower | 8.55 GB less (86.68%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 12s | near tie | 8.45 GB less (85.67%) |
| Discourse Test Image | Commit Build | 0m 10s | 0m 9s | near tie | 7.92 GB less (80.3%) |
| PostHog | Commit Build | 14m 3s | 11m 46s | 16% faster | 3.21 GB less (32.55%) |
| Storybook | Commit Build | 3m 40s | 3m 43s | near tie | 4.09 GB less (80.3%) |
| OpenTelemetry Java | Commit Build | 1m 24s | 1m 45s | 25% slower | 2.32 GB less (58.21%) |
| Spring AI | Commit Build | 1m 16s | 0m 57s | 25% faster | 3.19 GB less (70.59%) |
| gRPC | Commit Build | 1m 33s | 0m 35s | 62% faster | n/a |
| Zed | Commit Build | 35m 27s | 41m 31s | 17% slower | 10.55 GB less (92.52%) |
| n8n | Commit Build | 3m 45s | 2m 14s | 40% faster | 8.08 GB less (91.67%) |
| n8n Docker | Commit Build | 5m 7s | 3m 59s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 25s | 0m 52s | 39% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 0s | 1m 44s | 13% faster | n/a |
