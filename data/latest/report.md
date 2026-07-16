# Latest Benchmark Report

Generated: 2026-07-16 05:36 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 10s | 18% faster | 36.28 MB less (11.96%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 14s | 10m 57s | near tie | 49.71 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 22s | 31% faster | 176.38 MB less (18.7%) |
| gRPC | Cold Build | 25m 0s | 24m 40s | near tie | n/a |
| Zed | Warm Build | 20m 40s | 19m 17s | 7% faster | 2.13 GB less (78.15%) |
| n8n | Warm Build | 1m 28s | 0m 57s | 35% faster | 7.61 MB more (0.99%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 18s | 2m 27s | 26% faster | 1.18 GB less (77.73%) |
| Hugo Go | Commit Build | 1m 39s | 0m 50s | 49% faster | 1.01 GB less (79.5%) |
| Immich | Commit Build | 4m 44s | 3m 21s | 29% faster | 6.75 GB less (71.8%) |
| Mastodon | Commit Build | 2m 7s | 1m 56s | 9% faster | 8.95 GB less (89.64%) |
| Mastodon Streaming | Commit Build | 0m 9s | 0m 10s | near tie | 9.89 GB less (98.99%) |
| Discourse | Commit Build | 3m 21s | 3m 1s | 10% faster | 8.96 GB less (89.68%) |
| Discourse Base Deps | Commit Build | 0m 10s | 0m 9s | near tie | 9.29 GB less (92.97%) |
| Discourse Web-Only Image | Commit Build | 0m 9s | 0m 9s | near tie | 8.59 GB less (85.97%) |
| Discourse Release Image | Commit Build | 0m 14s | 0m 12s | near tie | 8.49 GB less (84.97%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 12s | near tie | 8.05 GB less (80.5%) |
| PostHog | Commit Build | 21m 58s | 18m 36s | 15% faster | 2.94 GB less (29.41%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 44s | 1m 3s | 39% faster | 3.14 GB less (80.5%) |
| Spring AI | Commit Build | 1m 1s | 0m 27s | 56% faster | 3.22 GB less (70.36%) |
| gRPC | Commit Build | 1m 38s | 0m 36s | 63% faster | n/a |
| Zed | Commit Build | 33m 22s | 33m 12s | near tie | 10.56 GB less (92.29%) |
| n8n | Commit Build | 5m 24s | 3m 30s | 35% faster | 14.13 GB less (94.78%) |
| n8n Docker | Commit Build | 5m 41s | 4m 46s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 55s | 0m 52s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 2m 35s | 1m 38s | 37% faster | n/a |
