# Latest Benchmark Report

Generated: 2026-07-16 20:52 UTC

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
| Immich | Commit Build | 0m 8s | 0m 12s | near tie | 8.44 GB less (76.29%) |
| Mastodon | Commit Build | 10m 25s | 9m 35s | investigation only | 8.89 GB less (89.6%) |
| Mastodon Streaming | Commit Build | 0m 20s | 0m 19s | near tie | 9.80 GB less (98.98%) |
| Discourse | Commit Build | 4m 12s | 3m 7s | 26% faster | 8.94 GB less (89.66%) |
| Discourse Base Deps | Commit Build | 0m 10s | 0m 12s | near tie | 9.27 GB less (92.96%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 11s | near tie | 8.57 GB less (85.94%) |
| Discourse Release Image | Commit Build | 0m 20s | 0m 11s | 45% faster | 8.47 GB less (84.94%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 8s | 43% faster | 8.03 GB less (80.46%) |
| PostHog | Commit Build | 27m 29s | 18m 35s | 32% faster | 6.28 GB less (47.0%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 32s | 1m 34s | near tie | 3.24 GB less (80.69%) |
| Spring AI | Commit Build | 3m 50s | 3m 44s | near tie | 3.22 GB less (70.37%) |
| gRPC | Commit Build | 21m 33s | 14m 0s | 35% faster | n/a |
| Zed | Commit Build | 46m 34s | 43m 49s | 6% faster | 10.58 GB less (92.3%) |
| n8n | Commit Build | 2m 21s | 1m 22s | 42% faster | 14.98 GB less (95.05%) |
| n8n Docker | Commit Build | 5m 39s | 4m 51s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 5s | 0m 51s | 22% faster | n/a |
| n8n Runners Distroless | Commit Build | 3m 6s | 1m 47s | 42% faster | n/a |
