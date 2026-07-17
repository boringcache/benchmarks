# Latest Benchmark Report

Generated: 2026-07-17 17:00 UTC

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
| Immich | Commit Build | 0m 25s | 0m 55s | 120% slower | 6.70 GB less (71.81%) |
| Mastodon | Commit Build | 2m 5s | 1m 51s | 11% faster | 8.94 GB less (89.65%) |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 15s | 88% slower | 9.87 GB less (98.99%) |
| Discourse | Commit Build | 4m 1s | 3m 12s | 20% faster | 8.75 GB less (89.45%) |
| Discourse Base Deps | Commit Build | 0m 15s | 0m 10s | near tie | 9.08 GB less (92.82%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 22s | 175% slower | 8.38 GB less (85.66%) |
| Discourse Release Image | Commit Build | 0m 14s | 0m 11s | near tie | 8.28 GB less (84.65%) |
| Discourse Test Image | Commit Build | 0m 11s | 0m 10s | near tie | 7.75 GB less (79.24%) |
| PostHog | Commit Build | 21m 52s | 18m 53s | 14% faster | 2.88 GB less (28.88%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 8m 25s | 7m 28s | 11% faster | 3.26 GB less (80.82%) |
| Spring AI | Commit Build | 1m 29s | 1m 23s | 7% faster | 3.23 GB less (70.48%) |
| gRPC | Commit Build | 2m 44s | 0m 39s | 76% faster | n/a |
| Zed | Commit Build | 40m 17s | 39m 32s | near tie | 10.55 GB less (92.29%) |
| n8n | Commit Build | 3m 49s | 2m 34s | 33% faster | 7.55 GB less (90.54%) |
| n8n Docker | Commit Build | 5m 6s | 4m 33s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 10s | 0m 56s | 20% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 30s | 1m 39s | 34% faster | n/a |
