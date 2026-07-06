# Latest Benchmark Report

Generated: 2026-07-06 10:19 UTC

Coverage: 20 benchmarks; fresh 6/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 31s | 3m 36s | near tie | 48.52 MB more (6.19%) |
| OpenTelemetry Java | Warm Build | 1m 1s | 0m 59s | 3% faster | 49.63 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 23s | 28% faster | 177.03 MB less (17.99%) |
| gRPC | Cold Build | 32m 56s | 23m 35s | 28% faster | n/a |
| Zed | Cold Build | 54m 28s | 52m 9s | 4% faster | 2.11 GB less (75.65%) |
| n8n | Cold Build | 5m 41s | 5m 47s | near tie | 9.61 MB more (1.32%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 7s | 3m 33s | cache import unavailable | 815.05 MB less (70.09%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 3m 37s | 3m 4s | 15% faster | 6.69 GB less (71.75%) |
| Mastodon | Commit Build | 0m 15s | 0m 13s | near tie | 8.96 GB less (89.75%) |
| Mastodon Streaming | Commit Build | 0m 12s | 0m 10s | near tie | 9.88 GB less (98.99%) |
| Discourse | Commit Build | 3m 35s | 3m 10s | 12% faster | 8.84 GB less (89.59%) |
| Discourse Base Deps | Commit Build | 0m 16s | 6m 50s | investigation only | 9.37 GB less (93.03%) |
| Discourse Web-Only Image | Commit Build | 0m 9s | 0m 9s | near tie | 8.75 GB less (86.94%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 11s | near tie | 8.65 GB less (85.96%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 11s | near tie | 8.13 GB less (80.71%) |
| PostHog | Commit Build | 18m 36s | 12m 0s | 35% faster | 4.66 GB less (40.26%) |
| Storybook | Commit Build | 3m 46s | 3m 19s | 12% faster | 4.31 GB less (80.93%) |
| OpenTelemetry Java | Commit Build | 9m 6s | 7m 23s | 19% faster | 2.31 GB less (58.09%) |
| Spring AI | Commit Build | 2m 3s | 2m 12s | 7% slower | 3.19 GB less (70.56%) |
| gRPC | Commit Build | 8m 30s | 6m 8s | 28% faster | n/a |
| Zed | Commit Build | 35m 27s | 41m 31s | 17% slower | 10.55 GB less (92.52%) |
| n8n | Commit Build | 6m 44s | 5m 12s | 23% faster | 4.34 GB less (85.53%) |
| n8n Docker | Commit Build | 5m 7s | 3m 59s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 25s | 0m 52s | 39% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 0s | 1m 44s | 13% faster | n/a |
