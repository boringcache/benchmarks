# Latest Benchmark Report

Generated: 2026-07-21 13:08 UTC

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
| Immich | Commit Build | 7m 7s | 5m 40s | investigation only | 6.65 GB less (69.79%) |
| Mastodon | Commit Build | 2m 6s | 1m 55s | 9% faster | 7.51 GB less (87.9%) |
| Mastodon Streaming | Commit Build | 0m 12s | 0m 8s | near tie | 8.44 GB less (98.82%) |
| Discourse | Commit Build | 3m 20s | 3m 5s | 8% faster | 8.93 GB less (89.64%) |
| Discourse Base Deps | Commit Build | 0m 21s | 0m 11s | 48% faster | 9.26 GB less (92.95%) |
| Discourse Web-Only Image | Commit Build | 0m 11s | 0m 11s | near tie | 8.56 GB less (85.92%) |
| Discourse Release Image | Commit Build | 0m 12s | 0m 15s | near tie | 8.46 GB less (84.93%) |
| Discourse Test Image | Commit Build | 0m 16s | 0m 9s | 44% faster | 8.02 GB less (80.44%) |
| PostHog | Commit Build | 20m 37s | 18m 50s | 9% faster | 2.80 GB less (28.21%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 18s | 1m 7s | 14% faster | 3.30 GB less (80.99%) |
| Spring AI | Commit Build | 2m 51s | 3m 51s | 35% slower | 3.26 GB less (70.17%) |
| gRPC | Commit Build | 2m 44s | 0m 39s | 76% faster | n/a |
| Zed | Commit Build | 37m 14s | 40m 53s | 10% slower | 10.60 GB less (92.18%) |
| n8n | Commit Build | 3m 15s | 3m 22s | 4% slower | 2.12 GB less (72.86%) |
| n8n Docker | Commit Build | 5m 20s | 5m 0s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 54s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 2m 14s | 2m 14s | near tie | n/a |
