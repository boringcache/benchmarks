# Latest Benchmark Report

Generated: 2026-05-29 10:03 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 8s | 0m 6s | near tie | 2.25 GB less (87.01%) |
| Hugo Go | Cold Build | 1m 7s | 1m 19s | 18% slower | 44.10 MB less (14.81%) |
| Immich | Cold Build | 5m 49s | 4m 50s | 17% faster | 7.82 GB less (79.02%) |
| Mastodon | Warm Build | 0m 12s | 0m 10s | near tie | 9.60 GB less (90.4%) |
| Mastodon Streaming | Warm Build | 0m 13s | 0m 7s | 46% faster | 9.92 GB less (98.99%) |
| Discourse | Cold Build | 5m 25s | 5m 15s | 3% faster | 9.16 GB less (90.0%) |
| Discourse Base Deps | Cold Build | 4m 38s | 4m 38s | near tie | 9.25 GB less (93.48%) |
| Discourse Web-Only Image | Warm Build | 0m 11s | 0m 6s | near tie | 9.21 GB less (88.02%) |
| Discourse Release Image | Cold Build | 11m 14s | 8m 25s | 25% faster | 11.42 GB less (89.41%) |
| Discourse Test Image | Cold Build | 7m 46s | 7m 30s | 3% faster | 8.53 GB less (81.57%) |
| PostHog | Warm Build | 0m 16s | 0m 11s | near tie | 8.28 GB less (56.27%) |
| Storybook | Cold Build | 3m 45s | 3m 31s | 6% faster | 44.74 MB more (6.12%) |
| OpenTelemetry Java | Cold Build | 11m 16s | 9m 23s | 17% faster | 51.51 MB less (5.76%) |
| Spring AI | Warm Build | 0m 31s | 0m 26s | near tie | 177.30 MB less (18.59%) |
| gRPC | Cold Build | 32m 7s | 22m 43s | 29% faster | n/a |
| Zed | Cold Build | 54m 55s | 51m 33s | 6% faster | 2.15 GB less (74.81%) |
| n8n | Cold Build | 5m 25s | 5m 32s | near tie | 15.38 MB more (2.16%) |
| n8n Docker | Cold Build | 4m 13s | 3m 50s | 9% faster | n/a |
| n8n Runners | Warm Build | 1m 46s | 0m 46s | 57% faster | n/a |
| n8n Runners Distroless | Cold Build | 1m 51s | 1m 45s | 5% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 10s | 0m 8s | near tie | 2.60 GB less (88.58%) |
| Hugo Go | Commit Build | 0m 39s | 0m 28s | 28% faster | 1.31 GB less (82.55%) |
| Immich | Commit Build | 0m 17s | 0m 13s | near tie | 7.83 GB less (79.02%) |
| Mastodon | Commit Build | 4m 15s | 2m 53s | 32% faster | 8.90 GB less (89.71%) |
| Mastodon Streaming | Commit Build | 0m 24s | 0m 21s | near tie | 9.82 GB less (98.98%) |
| Discourse | Commit Build | 3m 16s | 2m 44s | 16% faster | 8.94 GB less (89.76%) |
| Discourse Base Deps | Commit Build | 0m 19s | 0m 8s | 58% faster | 9.32 GB less (93.53%) |
| Discourse Web-Only Image | Commit Build | 0m 9s | 0m 7s | near tie | 8.71 GB less (87.42%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 11s | near tie | 8.61 GB less (86.42%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 10s | near tie | 8.03 GB less (80.62%) |
| PostHog | Commit Build | 15m 25s | 12m 28s | 19% faster | 3.78 GB less (38.0%) |
| Storybook | Commit Build | 3m 31s | 3m 27s | near tie | 1.95 GB less (71.29%) |
| OpenTelemetry Java | Commit Build | 5m 21s | 4m 44s | 12% faster | 3.12 GB less (77.86%) |
| Spring AI | Commit Build | 0m 55s | 0m 39s | 29% faster | 2.70 GB less (75.56%) |
| gRPC | Commit Build | 1m 9s | 1m 7s | near tie | n/a |
| Zed | Commit Build | 36m 22s | 35m 59s | near tie | 10.74 GB less (93.34%) |
| n8n | Commit Build | 6m 21s | 5m 8s | 19% faster | 3.91 GB less (83.5%) |
| n8n Docker | Commit Build | 3m 48s | 3m 34s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 14s | 0m 48s | 35% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 57s | 1m 26s | 26% faster | n/a |
