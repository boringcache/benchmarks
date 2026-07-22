# Latest Benchmark Report

Generated: 2026-07-22 18:23 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 21s | 1m 20s | near tie | 36.20 MB less (11.94%) |
| Storybook | Cold Build | 3m 16s | 3m 1s | 8% faster | 40.38 MB more (4.61%) |
| OpenTelemetry Java | Warm Build | 0m 54s | 0m 50s | near tie | 48.52 MB less (6.09%) |
| Spring AI | Cold Build | 4m 23s | 4m 31s | 3% slower | 176.76 MB less (18.73%) |
| gRPC | Cold Build | 39m 10s | 23m 36s | 40% faster | n/a |
| Zed | Cold Build | 56m 3s | 56m 10s | near tie | 2.12 GB less (78.07%) |
| n8n | Cold Build | 4m 36s | 3m 58s | 14% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 16s | 2m 19s | 29% faster | 1.94 GB less (85.13%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 0m 41s | 0m 26s | 37% faster | 8.48 GB less (74.64%) |
| Mastodon | Commit Build | 2m 7s | 1m 55s | 9% faster | 7.97 GB less (88.52%) |
| Mastodon Streaming | Commit Build | 0m 18s | 0m 11s | 39% faster | 8.90 GB less (98.88%) |
| Discourse | Commit Build | 3m 19s | 3m 5s | 7% faster | 8.88 GB less (89.58%) |
| Discourse Base Deps | Commit Build | 0m 13s | 0m 19s | 46% slower | 9.21 GB less (92.91%) |
| Discourse Web-Only Image | Commit Build | 0m 10s | 1m 42s | 920% slower | 8.59 GB less (86.67%) |
| Discourse Release Image | Commit Build | 0m 15s | 0m 10s | near tie | 8.49 GB less (85.67%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 13s | near tie | 7.96 GB less (80.32%) |
| PostHog | Commit Build | 29m 9s | 30m 16s | 4% slower | 2.92 GB less (28.99%) |
| Storybook | Commit Build | 1m 23s | 0m 51s | 39% faster | 5.64 GB less (86.28%) |
| OpenTelemetry Java | Commit Build | 1m 25s | 1m 4s | 25% faster | 2.94 GB less (80.1%) |
| Spring AI | Commit Build | 0m 48s | 0m 31s | 35% faster | 3.27 GB less (70.22%) |
| gRPC | Commit Build | 2m 15s | 1m 29s | 34% faster | n/a |
| Zed | Commit Build | 45m 49s | 49m 13s | 7% slower | 10.60 GB less (92.17%) |
| n8n | Commit Build | 4m 1s | 3m 54s | near tie | 3.31 GB less (80.72%) |
| n8n Docker | Commit Build | 6m 29s | 4m 59s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 7s | 0m 56s | 16% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 42s | 2m 14s | 31% slower | n/a |
