# Latest Benchmark Report

Generated: 2026-07-10 13:20 UTC

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
| n8n | Cold Build | 5m 27s | 5m 42s | 5% slower | 7.54 MB more (1.03%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 17s | 0m 7s | 59% faster | 1.59 GB less (82.4%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 3m 36s | 2m 43s | 25% faster | 7.29 GB less (73.38%) |
| Mastodon | Commit Build | 2m 12s | 1m 50s | 17% faster | 8.96 GB less (89.64%) |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 7s | near tie | 10.18 GB less (99.02%) |
| Discourse | Commit Build | 3m 37s | 3m 3s | 16% faster | 8.49 GB less (89.2%) |
| Discourse Base Deps | Commit Build | 0m 11s | 0m 13s | near tie | 9.17 GB less (92.88%) |
| Discourse Web-Only Image | Commit Build | 0m 9s | 0m 8s | near tie | 8.55 GB less (86.66%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 9s | near tie | 8.45 GB less (85.66%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 11s | near tie | 7.92 GB less (80.3%) |
| PostHog | Commit Build | 25m 47s | 14m 20s | 44% faster | 5.20 GB less (43.52%) |
| Storybook | Commit Build | 4m 17s | 3m 25s | 20% faster | 5.15 GB less (85.97%) |
| OpenTelemetry Java | Commit Build | 1m 16s | 1m 10s | 8% faster | 2.86 GB less (79.06%) |
| Spring AI | Commit Build | 0m 40s | 0m 28s | 30% faster | 3.22 GB less (70.34%) |
| gRPC | Commit Build | 8m 20s | 4m 55s | 41% faster | n/a |
| Zed | Commit Build | 36m 35s | 39m 31s | 8% slower | 10.58 GB less (92.31%) |
| n8n | Commit Build | 5m 29s | 4m 6s | 25% faster | 11.52 GB less (93.75%) |
| n8n Docker | Commit Build | 5m 22s | 5m 9s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 24s | 0m 49s | 42% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 35s | 1m 26s | 45% faster | n/a |
