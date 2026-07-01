# Latest Benchmark Report

Generated: 2026-07-01 01:36 UTC

Coverage: 20 benchmarks; fresh 6/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 20s | 3m 35s | 8% slower | 47.13 MB more (6.01%) |
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
| Immich | Commit Build | 5m 24s | 3m 47s | 30% faster | 7.28 GB less (73.45%) |
| Mastodon | Commit Build | 0m 21s | 0m 14s | 33% faster | 8.93 GB less (89.73%) |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 12s | near tie | 9.85 GB less (98.98%) |
| Discourse | Commit Build | 3m 15s | 3m 7s | 4% faster | 8.94 GB less (89.7%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 15s | 88% slower | 9.54 GB less (93.16%) |
| Discourse Web-Only Image | Commit Build | 0m 13s | 0m 12s | near tie | 8.65 GB less (86.83%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 21s | 110% slower | 8.83 GB less (86.22%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 12s | near tie | 8.03 GB less (80.56%) |
| PostHog | Commit Build | 14m 26s | 11m 0s | 24% faster | 3.39 GB less (34.23%) |
| Storybook | Commit Build | 1m 27s | 1m 39s | 14% slower | 3.98 GB less (79.98%) |
| OpenTelemetry Java | Commit Build | 11m 10s | 7m 28s | 33% faster | 1.86 GB less (52.79%) |
| Spring AI | Commit Build | 0m 58s | 0m 49s | 16% faster | 3.18 GB less (70.67%) |
| gRPC | Commit Build | 1m 31s | 0m 36s | 60% faster | n/a |
| Zed | Commit Build | 35m 27s | 41m 31s | 17% slower | 10.55 GB less (92.52%) |
| n8n | Commit Build | 4m 51s | 4m 3s | 16% faster | 7.34 GB less (90.91%) |
| n8n Docker | Commit Build | 4m 54s | 3m 58s | 19% faster | n/a |
| n8n Runners | Commit Build | 1m 2s | 0m 52s | 16% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 5s | 1m 46s | 15% faster | n/a |
