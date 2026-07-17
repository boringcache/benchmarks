# Latest Benchmark Report

Generated: 2026-07-17 20:55 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 10s | 18% faster | 36.28 MB less (11.96%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 14s | 10m 57s | near tie | 49.71 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 22s | 31% faster | 176.38 MB less (18.7%) |
| gRPC | Cold Build | 38m 14s | 23m 20s | 39% faster | n/a |
| Zed | Warm Build | 19m 25s | 16m 50s | 13% faster | 2.11 GB less (78.0%) |
| n8n | Warm Build | 1m 28s | 0m 57s | 35% faster | 7.61 MB more (0.99%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 18s | 2m 27s | 26% faster | 1.18 GB less (77.73%) |
| Hugo Go | Commit Build | 1m 39s | 0m 50s | 49% faster | 1.01 GB less (79.5%) |
| Immich | Commit Build | 0m 9s | 0m 9s | near tie | 6.70 GB less (71.81%) |
| Mastodon | Commit Build | 2m 5s | 1m 51s | 11% faster | 8.94 GB less (89.65%) |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 15s | 88% slower | 9.87 GB less (98.99%) |
| Discourse | Commit Build | 3m 53s | 3m 3s | 21% faster | 8.75 GB less (89.45%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 12s | near tie | 9.08 GB less (92.82%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 11s | near tie | 8.38 GB less (85.66%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 11s | near tie | 8.28 GB less (84.65%) |
| Discourse Test Image | Commit Build | 0m 23s | 0m 11s | 52% faster | 7.75 GB less (79.24%) |
| PostHog | Commit Build | 16m 4s | 13m 11s | 18% faster | 2.39 GB less (25.13%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 18s | 1m 7s | 14% faster | 3.30 GB less (80.99%) |
| Spring AI | Commit Build | 1m 29s | 1m 23s | 7% faster | 3.23 GB less (70.48%) |
| gRPC | Commit Build | 2m 44s | 0m 39s | 76% faster | n/a |
| Zed | Commit Build | 45m 53s | 44m 46s | near tie | 10.56 GB less (92.16%) |
| n8n | Commit Build | 4m 49s | 2m 13s | 54% faster | 16.04 GB less (95.31%) |
| n8n Docker | Commit Build | 6m 25s | 4m 22s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 26s | 0m 53s | 38% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 50s | 1m 42s | 7% faster | n/a |
