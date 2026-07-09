# Latest Benchmark Report

Generated: 2026-07-09 17:26 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 22s | 4% faster | 36.28 MB less (11.96%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 29s | 10m 55s | 5% faster | 49.73 MB less (6.09%) |
| Spring AI | Warm Build | 0m 34s | 0m 27s | 21% faster | 176.12 MB less (17.96%) |
| gRPC | Cold Build | 33m 31s | 25m 3s | 25% faster | n/a |
| Zed | Cold Build | 54m 32s | 54m 54s | near tie | 2.13 GB less (78.15%) |
| n8n | Cold Build | 5m 27s | 5m 42s | 5% slower | 7.54 MB more (1.03%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 17s | 0m 7s | 59% faster | 1.59 GB less (82.4%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 0m 19s | 0m 13s | 32% faster | 7.80 GB less (74.6%) |
| Mastodon | Commit Build | 2m 23s | 1m 59s | 17% faster | 8.93 GB less (89.61%) |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 10s | near tie | 9.86 GB less (98.99%) |
| Discourse | Commit Build | 3m 22s | 2m 57s | 12% faster | 8.88 GB less (89.62%) |
| Discourse Base Deps | Commit Build | 0m 15s | 0m 8s | 47% faster | 9.20 GB less (92.91%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 11s | near tie | 8.59 GB less (86.72%) |
| Discourse Release Image | Commit Build | 0m 15s | 0m 10s | near tie | 8.49 GB less (85.71%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 9s | near tie | 7.96 GB less (80.39%) |
| PostHog | Commit Build | 18m 3s | 20m 57s | 16% slower | 4.96 GB less (42.42%) |
| Storybook | Commit Build | 4m 2s | 3m 6s | 23% faster | 4.97 GB less (85.7%) |
| OpenTelemetry Java | Commit Build | 1m 29s | 1m 25s | 4% faster | 3.09 GB less (80.3%) |
| Spring AI | Commit Build | 0m 52s | 0m 50s | near tie | 3.20 GB less (70.43%) |
| gRPC | Commit Build | 20m 6s | 12m 34s | 37% faster | n/a |
| Zed | Commit Build | 23m 38s | 23m 2s | near tie | 10.58 GB less (92.31%) |
| n8n | Commit Build | 3m 3s | 2m 21s | 23% faster | 11.19 GB less (93.8%) |
| n8n Docker | Commit Build | 6m 2s | 4m 49s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 5s | 0m 55s | 15% faster | n/a |
| n8n Runners Distroless | Commit Build | 3m 1s | 1m 34s | 48% faster | n/a |
