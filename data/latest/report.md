# Latest Benchmark Report

Generated: 2026-07-23 16:31 UTC

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
| Immich | Commit Build | 4m 6s | 2m 56s | 28% faster | 6.68 GB less (69.88%) |
| Mastodon | Commit Build | 3m 0s | 1m 38s | 46% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 7s | near tie | n/a |
| Discourse | Commit Build | 3m 53s | 2m 41s | 31% faster | 8.90 GB less (89.6%) |
| Discourse Base Deps | Commit Build | 0m 13s | 0m 8s | near tie | 9.59 GB less (93.18%) |
| Discourse Web-Only Image | Commit Build | 0m 18s | 0m 13s | near tie | 8.61 GB less (86.7%) |
| Discourse Release Image | Commit Build | 0m 17s | 0m 10s | 41% faster | 8.51 GB less (85.7%) |
| Discourse Test Image | Commit Build | 0m 21s | 0m 8s | 62% faster | 7.98 GB less (80.36%) |
| PostHog | Commit Build | 21m 31s | 13m 33s | 37% faster | n/a |
| Storybook | Commit Build | 3m 4s | 2m 44s | 11% faster | 854.62 MB less (48.24%) |
| OpenTelemetry Java | Commit Build | 6m 55s | 10m 13s | 48% slower | 2.44 GB less (78.94%) |
| Spring AI | Commit Build | 4m 18s | 4m 19s | near tie | 205.07 MB more (21.74%) |
| gRPC | Commit Build | 2m 16s | 0m 40s | 71% faster | n/a |
| Zed | Commit Build | 21m 9s | 45m 14s | 114% slower | 8.79 GB less (76.4%) |
| n8n | Commit Build | 1m 50s | 2m 26s | 33% slower | 658.95 MB more (27.38%) |
| n8n Docker | Commit Build | 4m 56s | 2m 54s | 41% faster | n/a |
| n8n Runners | Commit Build | 1m 17s | 0m 39s | 49% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 51s | 1m 7s | 40% faster | n/a |
