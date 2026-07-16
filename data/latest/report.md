# Latest Benchmark Report

Generated: 2026-07-16 09:25 UTC

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
| Discourse Base Deps | Commit Build | 0m 7s | 0m 8s | near tie | 9.12 GB less (92.85%) |
| Discourse Web-Only Image | Commit Build | 0m 16s | 0m 11s | near tie | 8.42 GB less (85.72%) |
| Discourse Release Image | Commit Build | 0m 15s | 0m 14s | near tie | 8.32 GB less (84.71%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 9s | near tie | 7.87 GB less (80.16%) |
| PostHog | Commit Build | 23m 33s | 19m 17s | 18% faster | 3.91 GB less (35.66%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 44s | 1m 3s | 39% faster | 3.14 GB less (80.5%) |
| Spring AI | Commit Build | 1m 1s | 0m 27s | 56% faster | 3.22 GB less (70.36%) |
| gRPC | Commit Build | 3m 10s | 0m 39s | 79% faster | n/a |
| Zed | Commit Build | 27m 33s | 25m 44s | 7% faster | 10.52 GB less (92.27%) |
| n8n | Commit Build | 4m 49s | 4m 15s | 12% faster | 14.33 GB less (94.84%) |
| n8n Docker | Commit Build | 5m 20s | 4m 46s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 34s | 0m 53s | 44% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 5s | 1m 38s | 22% faster | n/a |
