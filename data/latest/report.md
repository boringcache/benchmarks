# Latest Benchmark Report

Generated: 2026-07-21 09:26 UTC

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
| Immich | Commit Build | 9m 39s | 5m 42s | 41% faster | 7.18 GB less (73.21%) |
| Mastodon | Commit Build | 0m 18s | 0m 17s | near tie | 7.83 GB less (88.33%) |
| Mastodon Streaming | Commit Build | 0m 10s | 0m 10s | near tie | 8.44 GB less (98.82%) |
| Discourse | Commit Build | 4m 7s | 3m 11s | 23% faster | 9.28 GB less (89.99%) |
| Discourse Base Deps | Commit Build | 0m 16s | 0m 16s | near tie | 9.61 GB less (93.19%) |
| Discourse Web-Only Image | Commit Build | 0m 19s | 0m 12s | 37% faster | 8.91 GB less (86.4%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 13s | near tie | 8.81 GB less (85.44%) |
| Discourse Test Image | Commit Build | 0m 13s | 0m 14s | near tie | 8.36 GB less (81.1%) |
| PostHog | Commit Build | 20m 57s | 19m 36s | 6% faster | 2.79 GB less (28.12%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 18s | 1m 7s | 14% faster | 3.30 GB less (80.99%) |
| Spring AI | Commit Build | 1m 29s | 1m 23s | 7% faster | 3.23 GB less (70.48%) |
| gRPC | Commit Build | 2m 44s | 0m 39s | 76% faster | n/a |
| Zed | Commit Build | 40m 40s | 40m 20s | near tie | 10.59 GB less (92.17%) |
| n8n | Commit Build | 4m 10s | 3m 56s | 6% faster | 1.77 GB less (69.13%) |
| n8n Docker | Commit Build | 4m 24s | 4m 54s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 56s | 0m 55s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 2m 20s | 1m 44s | 26% faster | n/a |
