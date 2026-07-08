# Latest Benchmark Report

Generated: 2026-07-08 17:10 UTC

Coverage: 20 benchmarks; fresh 5/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Warm Build | 0m 53s | 0m 46s | 13% faster | 47.04 MB more (6.0%) |
| OpenTelemetry Java | Warm Build | 1m 1s | 0m 59s | 3% faster | 49.63 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 23s | 28% faster | 177.03 MB less (17.99%) |
| gRPC | Cold Build | 32m 56s | 23m 35s | 28% faster | n/a |
| n8n | Cold Build | 5m 41s | 5m 47s | near tie | 9.61 MB more (1.32%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 49s | 2m 44s | near tie | 1.60 GB less (82.52%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 5m 47s | 3m 57s | 32% faster | 7.12 GB less (72.91%) |
| Mastodon | Commit Build | 0m 16s | 0m 16s | near tie | 9.25 GB less (90.02%) |
| Mastodon Streaming | Commit Build | 0m 12s | 0m 9s | near tie | 9.89 GB less (98.99%) |
| Discourse | Commit Build | 3m 18s | 3m 2s | 8% faster | 8.73 GB less (89.47%) |
| Discourse Base Deps | Commit Build | 0m 7s | 0m 8s | near tie | 9.06 GB less (92.81%) |
| Discourse Web-Only Image | Commit Build | 0m 14s | 0m 14s | near tie | 8.45 GB less (86.53%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 11s | near tie | 8.35 GB less (85.51%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 11s | near tie | 7.82 GB less (80.1%) |
| PostHog | Commit Build | 22m 25s | 12m 57s | 42% faster | 3.98 GB less (37.0%) |
| Storybook | Commit Build | 4m 20s | 3m 47s | 13% faster | 4.90 GB less (85.54%) |
| OpenTelemetry Java | Commit Build | 5m 54s | 5m 30s | 7% faster | 3.13 GB less (80.52%) |
| Spring AI | Commit Build | 1m 2s | 0m 44s | 29% faster | 3.20 GB less (70.43%) |
| gRPC | Commit Build | 7m 26s | 5m 43s | 23% faster | n/a |
| Zed | Commit Build | 42m 10s | 44m 25s | 5% slower | 10.58 GB less (92.32%) |
| n8n | Commit Build | 2m 50s | 2m 6s | 26% faster | 11.08 GB less (93.74%) |
| n8n Docker | Commit Build | 7m 2s | 4m 26s | 37% faster | n/a |
| n8n Runners | Commit Build | 1m 17s | 0m 49s | 36% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 59s | 1m 40s | 44% faster | n/a |
