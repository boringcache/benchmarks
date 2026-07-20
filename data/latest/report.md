# Latest Benchmark Report

Generated: 2026-07-20 13:21 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 24s | 1m 26s | near tie | 36.20 MB less (11.94%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 14s | 10m 57s | near tie | 49.71 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 22s | 31% faster | 176.38 MB less (18.7%) |
| gRPC | Cold Build | 38m 14s | 23m 20s | 39% faster | n/a |
| Zed | Warm Build | 19m 25s | 16m 50s | 13% faster | 2.11 GB less (78.0%) |
| n8n | Cold Build | 3m 54s | 3m 24s | 13% faster | 7.95 MB more (1.03%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 11s | 0m 8s | near tie | 119.70 MB less (25.62%) |
| Hugo Go | Commit Build | 1m 39s | 0m 50s | 49% faster | 1.01 GB less (79.5%) |
| Immich | Commit Build | 0m 11s | 0m 12s | near tie | 6.70 GB less (71.83%) |
| Mastodon | Commit Build | 2m 45s | 1m 56s | 30% faster | 8.94 GB less (89.64%) |
| Mastodon Streaming | Commit Build | 0m 12s | 0m 11s | near tie | 9.87 GB less (98.99%) |
| Discourse | Commit Build | 3m 21s | 3m 10s | 5% faster | 8.86 GB less (89.57%) |
| Discourse Base Deps | Commit Build | 0m 19s | 0m 11s | 42% faster | 9.26 GB less (92.95%) |
| Discourse Web-Only Image | Commit Build | 0m 12s | 0m 10s | near tie | 8.56 GB less (85.92%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 8s | 50% faster | 8.46 GB less (84.93%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 16s | 100% slower | 8.02 GB less (80.44%) |
| PostHog | Commit Build | 21m 10s | 18m 40s | 12% faster | 2.81 GB less (28.32%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 18s | 1m 7s | 14% faster | 3.30 GB less (80.99%) |
| Spring AI | Commit Build | 1m 29s | 1m 23s | 7% faster | 3.23 GB less (70.48%) |
| gRPC | Commit Build | 2m 44s | 0m 39s | 76% faster | n/a |
| Zed | Commit Build | 33m 39s | 40m 34s | 21% slower | 10.59 GB less (92.17%) |
| n8n | Commit Build | 2m 6s | 3m 1s | 44% slower | 1.29 GB less (61.96%) |
| n8n Docker | Commit Build | 5m 12s | 3m 19s | 36% faster | n/a |
| n8n Runners | Commit Build | 1m 1s | 0m 55s | 10% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 8s | 1m 46s | 17% faster | n/a |
