# Latest Benchmark Report

Generated: 2026-07-23 09:23 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 22s | 1m 24s | near tie | n/a |
| Storybook | Cold Build | 3m 16s | 3m 1s | 8% faster | 40.38 MB more (4.61%) |
| OpenTelemetry Java | Warm Build | 0m 54s | 0m 50s | near tie | 48.52 MB less (6.09%) |
| Spring AI | Cold Build | 4m 23s | 4m 31s | 3% slower | 176.76 MB less (18.73%) |
| gRPC | Cold Build | 39m 10s | 23m 36s | 40% faster | n/a |
| Zed | Cold Build | 53m 52s | 48m 36s | 10% faster | n/a |
| n8n | Cold Build | 4m 36s | 3m 58s | 14% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 16s | 2m 19s | 29% faster | 1.94 GB less (85.13%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 3m 56s | 6m 21s | 61% slower | 7.08 GB less (71.09%) |
| Mastodon | Commit Build | 2m 7s | 1m 55s | 9% faster | 7.97 GB less (88.52%) |
| Mastodon Streaming | Commit Build | 0m 18s | 0m 11s | 39% faster | 8.90 GB less (98.88%) |
| Discourse | Commit Build | 4m 2s | 2m 45s | 32% faster | 8.76 GB less (89.45%) |
| Discourse Base Deps | Commit Build | 0m 10s | 0m 8s | near tie | 9.43 GB less (93.07%) |
| Discourse Web-Only Image | Commit Build | 0m 7s | 0m 6s | near tie | 8.81 GB less (86.96%) |
| Discourse Release Image | Commit Build | 0m 14s | 0m 10s | near tie | 8.71 GB less (85.98%) |
| Discourse Test Image | Commit Build | 0m 16s | 0m 10s | 38% faster | 8.18 GB less (80.75%) |
| PostHog | Commit Build | 31m 27s | 14m 1s | 55% faster | n/a |
| Storybook | Commit Build | 1m 23s | 0m 51s | 39% faster | 5.64 GB less (86.28%) |
| OpenTelemetry Java | Commit Build | 4m 54s | 4m 53s | near tie | 2.63 GB less (78.27%) |
| Spring AI | Commit Build | 2m 4s | 3m 53s | 88% slower | 3.27 GB less (70.22%) |
| gRPC | Commit Build | 1m 55s | 0m 35s | 70% faster | n/a |
| Zed | Commit Build | 46m 50s | 44m 17s | 5% faster | n/a |
| n8n | Commit Build | 3m 25s | 3m 24s | near tie | 950.98 MB less (54.02%) |
| n8n Docker | Commit Build | 5m 38s | 3m 34s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 19s | 0m 43s | 46% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 42s | 1m 19s | 23% faster | n/a |
