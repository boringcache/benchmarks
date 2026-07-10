# Latest Benchmark Report

Generated: 2026-07-10 21:02 UTC

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
| Immich | Commit Build | 0m 8s | 0m 11s | near tie | 7.27 GB less (73.33%) |
| Mastodon | Commit Build | 2m 10s | 1m 54s | 12% faster | 8.96 GB less (89.65%) |
| Mastodon Streaming | Commit Build | 0m 6s | 0m 8s | near tie | 10.31 GB less (99.03%) |
| Discourse | Commit Build | 3m 11s | 3m 10s | near tie | 8.91 GB less (89.64%) |
| Discourse Base Deps | Commit Build | 0m 17s | 0m 10s | 41% faster | 9.23 GB less (92.93%) |
| Discourse Web-Only Image | Commit Build | 0m 14s | 0m 13s | near tie | 8.62 GB less (86.76%) |
| Discourse Release Image | Commit Build | 0m 17s | 0m 12s | near tie | 8.52 GB less (85.76%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 11s | near tie | 7.99 GB less (80.43%) |
| PostHog | Commit Build | 13m 2s | 11m 0s | 16% faster | 3.36 GB less (34.27%) |
| Storybook | Commit Build | 3m 42s | 2m 51s | 23% faster | 5.21 GB less (86.09%) |
| OpenTelemetry Java | Commit Build | 9m 16s | 9m 19s | near tie | 2.81 GB less (78.74%) |
| Spring AI | Commit Build | 0m 40s | 0m 28s | 30% faster | 3.22 GB less (70.34%) |
| gRPC | Commit Build | 1m 59s | 0m 40s | 66% faster | n/a |
| Zed | Commit Build | 40m 5s | 39m 26s | near tie | 10.58 GB less (92.31%) |
| n8n | Commit Build | 3m 8s | 2m 21s | 25% faster | 11.84 GB less (93.86%) |
| n8n Docker | Commit Build | 5m 58s | 5m 58s | near tie | n/a |
| n8n Runners | Commit Build | 1m 37s | 0m 57s | 41% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 6s | 1m 58s | 6% faster | n/a |
