# Latest Benchmark Report

Generated: 2026-07-23 13:08 UTC

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
| Immich | Commit Build | 5m 33s | 2m 3s | 63% faster | 6.72 GB less (70.0%) |
| Mastodon | Commit Build | 2m 51s | 1m 30s | 47% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 7s | near tie | n/a |
| Discourse | Commit Build | 4m 3s | 2m 49s | 30% faster | 8.91 GB less (89.62%) |
| Discourse Base Deps | Commit Build | 0m 12s | 0m 8s | near tie | 9.25 GB less (92.94%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 16s | 100% slower | 8.80 GB less (86.95%) |
| Discourse Release Image | Commit Build | 0m 12s | 0m 9s | near tie | 8.70 GB less (85.97%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 8s | 43% faster | 8.00 GB less (80.39%) |
| PostHog | Commit Build | 20m 45s | 13m 31s | 35% faster | n/a |
| Storybook | Commit Build | 3m 4s | 2m 55s | 5% faster | 46.82 MB more (5.34%) |
| OpenTelemetry Java | Commit Build | 4m 54s | 4m 53s | near tie | 2.63 GB less (78.27%) |
| Spring AI | Commit Build | 2m 4s | 3m 53s | 88% slower | 3.27 GB less (70.22%) |
| gRPC | Commit Build | 2m 16s | 0m 40s | 71% faster | n/a |
| Zed | Commit Build | 41m 23s | 40m 29s | near tie | 8.67 GB less (75.82%) |
| n8n | Commit Build | 2m 47s | 3m 19s | 19% slower | 1.24 GB less (61.09%) |
| n8n Docker | Commit Build | 5m 19s | 2m 36s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 36s | 33% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 16s | 1m 14s | 46% faster | n/a |
