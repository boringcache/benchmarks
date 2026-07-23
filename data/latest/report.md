# Latest Benchmark Report

Generated: 2026-07-23 17:09 UTC

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
| Mastodon | Commit Build | 0m 22s | 0m 15s | 32% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 13s | 0m 12s | near tie | n/a |
| Discourse | Commit Build | 3m 53s | 2m 41s | 31% faster | 8.90 GB less (89.6%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 21s | 163% slower | 9.58 GB less (93.17%) |
| Discourse Web-Only Image | Commit Build | 0m 29s | 0m 22s | 24% faster | 8.67 GB less (86.78%) |
| Discourse Release Image | Commit Build | 0m 17s | 0m 22s | near tie | 8.57 GB less (85.79%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 22s | 144% slower | 8.33 GB less (81.02%) |
| PostHog | Commit Build | 24m 18s | 0m 23s | 98% faster | n/a |
| Storybook | Commit Build | 3m 4s | 2m 44s | 11% faster | 854.62 MB less (48.24%) |
| OpenTelemetry Java | Commit Build | 6m 55s | 10m 13s | 48% slower | 2.44 GB less (78.94%) |
| Spring AI | Commit Build | 4m 18s | 4m 19s | near tie | 205.07 MB more (21.74%) |
| gRPC | Commit Build | 2m 16s | 0m 40s | 71% faster | n/a |
| Zed | Commit Build | 55m 54s | 41m 9s | 26% faster | 5.05 GB less (59.57%) |
| n8n | Commit Build | 2m 53s | 2m 50s | near tie | 601.60 MB more (24.52%) |
| n8n Docker | Commit Build | 4m 56s | 2m 54s | 41% faster | n/a |
| n8n Runners | Commit Build | 1m 17s | 0m 39s | 49% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 51s | 1m 7s | 40% faster | n/a |
