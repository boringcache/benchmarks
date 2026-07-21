# Latest Benchmark Report

Generated: 2026-07-21 15:32 UTC

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
| Immich | Commit Build | 4m 45s | 3m 28s | 27% faster | 7.05 GB less (71.0%) |
| Mastodon | Commit Build | 2m 36s | 2m 3s | 21% faster | 7.82 GB less (88.34%) |
| Mastodon Streaming | Commit Build | 0m 9s | 0m 10s | near tie | 8.76 GB less (98.86%) |
| Discourse | Commit Build | 3m 25s | 3m 5s | 10% faster | 8.80 GB less (89.5%) |
| Discourse Base Deps | Commit Build | 0m 12s | 0m 12s | near tie | 9.39 GB less (93.04%) |
| Discourse Web-Only Image | Commit Build | 0m 11s | 0m 8s | near tie | 8.69 GB less (86.1%) |
| Discourse Release Image | Commit Build | 0m 17s | 0m 16s | near tie | 8.59 GB less (85.12%) |
| Discourse Test Image | Commit Build | 0m 13s | 0m 16s | near tie | 8.14 GB less (80.69%) |
| PostHog | Commit Build | 27m 29s | 21m 44s | 21% faster | 3.76 GB less (34.5%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 18s | 1m 7s | 14% faster | 3.30 GB less (80.99%) |
| Spring AI | Commit Build | 2m 51s | 3m 51s | 35% slower | 3.26 GB less (70.17%) |
| gRPC | Commit Build | 2m 44s | 0m 39s | 76% faster | n/a |
| Zed | Commit Build | 33m 45s | 39m 50s | 18% slower | 10.58 GB less (92.16%) |
| n8n | Commit Build | 2m 39s | 2m 47s | 5% slower | 2.26 GB less (74.15%) |
| n8n Docker | Commit Build | 5m 2s | 4m 32s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 3s | 0m 51s | 19% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 22s | 1m 37s | 32% faster | n/a |
