# Latest Benchmark Report

Generated: 2026-07-17 09:19 UTC

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
| Immich | Commit Build | 0m 8s | 0m 12s | near tie | 8.44 GB less (76.29%) |
| Mastodon | Commit Build | 2m 5s | 2m 2s | near tie | 8.86 GB less (89.57%) |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 8s | near tie | 9.79 GB less (98.98%) |
| Discourse | Commit Build | 3m 31s | 3m 8s | 11% faster | 8.88 GB less (89.59%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 8s | near tie | 9.29 GB less (92.98%) |
| Discourse Web-Only Image | Commit Build | 0m 16s | 0m 10s | 38% faster | 8.59 GB less (85.97%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 14s | 75% slower | 8.50 GB less (84.97%) |
| Discourse Test Image | Commit Build | 0m 18s | 0m 9s | 50% faster | 7.97 GB less (79.68%) |
| PostHog | Commit Build | 24m 13s | 18m 28s | 24% faster | 4.51 GB less (38.87%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 4m 51s | 5m 26s | 12% slower | 3.27 GB less (80.86%) |
| Spring AI | Commit Build | 1m 7s | 1m 6s | near tie | 3.23 GB less (70.44%) |
| gRPC | Commit Build | 2m 44s | 0m 39s | 76% faster | n/a |
| Zed | Commit Build | 21m 46s | 16m 57s | 22% faster | 10.57 GB less (92.3%) |
| n8n | Commit Build | 5m 5s | 3m 55s | 23% faster | 7.23 GB less (90.19%) |
| n8n Docker | Commit Build | 4m 44s | 4m 13s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 21s | 0m 53s | 35% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 57s | 1m 33s | 21% faster | n/a |
