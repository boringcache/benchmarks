# Latest Benchmark Report

Generated: 2026-07-22 09:29 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 27s | 1m 25s | near tie | 36.23 MB less (11.95%) |
| Storybook | Warm Build | 1m 19s | 0m 55s | 30% faster | 40.36 MB more (4.6%) |
| OpenTelemetry Java | Cold Build | 18m 14s | 10m 55s | 40% faster | 48.45 MB less (6.08%) |
| Spring AI | Cold Build | 4m 34s | 4m 28s | near tie | 176.77 MB less (18.73%) |
| gRPC | Cold Build | 37m 41s | 18m 14s | 52% faster | n/a |
| Zed | Cold Build | 55m 30s | 54m 13s | near tie | 2.12 GB less (78.07%) |
| n8n | Cold Build | 3m 32s | 3m 37s | near tie | 7.65 MB more (0.99%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 11s | 0m 8s | near tie | 119.70 MB less (25.62%) |
| Hugo Go | Commit Build | 0m 16s | 0m 21s | near tie | 339.44 MB less (55.97%) |
| Immich | Commit Build | 0m 14s | 0m 11s | near tie | 7.07 GB less (71.04%) |
| Mastodon | Commit Build | 2m 9s | 2m 47s | 29% slower | 7.85 GB less (88.37%) |
| Mastodon Streaming | Commit Build | 0m 9s | 0m 9s | near tie | 8.78 GB less (98.86%) |
| Discourse | Commit Build | 3m 22s | 3m 34s | 6% slower | 8.71 GB less (89.41%) |
| Discourse Base Deps | Commit Build | 0m 12s | 0m 18s | 50% slower | 9.04 GB less (92.79%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 11s | near tie | 8.34 GB less (85.6%) |
| Discourse Release Image | Commit Build | 0m 12s | 0m 12s | near tie | 8.81 GB less (85.43%) |
| Discourse Test Image | Commit Build | 0m 13s | 0m 10s | near tie | 7.79 GB less (79.99%) |
| PostHog | Commit Build | 25m 41s | 18m 55s | 26% faster | 2.86 GB less (28.57%) |
| Storybook | Commit Build | 1m 24s | 0m 48s | 43% faster | 5.64 GB less (86.28%) |
| OpenTelemetry Java | Commit Build | 1m 14s | 1m 3s | 15% faster | 2.94 GB less (80.1%) |
| Spring AI | Commit Build | 0m 50s | 0m 40s | 20% faster | 3.26 GB less (70.17%) |
| gRPC | Commit Build | 1m 47s | 0m 46s | 57% faster | n/a |
| Zed | Commit Build | 41m 59s | 45m 24s | 8% slower | 10.59 GB less (92.16%) |
| n8n | Commit Build | 4m 44s | 3m 30s | 26% faster | 2.65 GB less (77.06%) |
| n8n Docker | Commit Build | 5m 26s | 4m 52s | 10% faster | n/a |
| n8n Runners | Commit Build | 1m 0s | 0m 54s | 10% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 1s | 2m 39s | 31% slower | n/a |
