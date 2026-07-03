# Latest Benchmark Report

Generated: 2026-07-03 09:44 UTC

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
| n8n | Cold Build | 5m 18s | 5m 34s | 5% slower | 10.17 MB more (1.4%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 7s | 3m 33s | cache import unavailable | 815.05 MB less (70.09%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 3m 37s | 3m 4s | 15% faster | 6.69 GB less (71.75%) |
| Mastodon | Commit Build | 2m 29s | 3m 23s | 36% slower | 8.91 GB less (89.71%) |
| Mastodon Streaming | Commit Build | 0m 6s | 0m 10s | near tie | 9.83 GB less (98.98%) |
| Discourse | Commit Build | 3m 35s | 3m 10s | 12% faster | 8.84 GB less (89.59%) |
| Discourse Base Deps | Commit Build | 0m 18s | 0m 10s | 44% faster | 9.27 GB less (92.96%) |
| Discourse Web-Only Image | Commit Build | 0m 11s | 0m 11s | near tie | 8.66 GB less (86.83%) |
| Discourse Release Image | Commit Build | 0m 17s | 0m 12s | near tie | 8.56 GB less (85.83%) |
| Discourse Test Image | Commit Build | 0m 13s | 0m 10s | near tie | 8.03 GB less (80.53%) |
| PostHog | Commit Build | 18m 32s | 22m 53s | 23% slower | 4.87 GB less (41.63%) |
| Storybook | Commit Build | 3m 49s | 3m 29s | 9% faster | 4.23 GB less (80.8%) |
| OpenTelemetry Java | Commit Build | 9m 6s | 7m 23s | 19% faster | 2.31 GB less (58.09%) |
| Spring AI | Commit Build | 2m 2s | 2m 7s | 4% slower | 3.19 GB less (70.59%) |
| gRPC | Commit Build | 1m 36s | 0m 29s | 70% faster | n/a |
| Zed | Commit Build | 35m 27s | 41m 31s | 17% slower | 10.55 GB less (92.52%) |
| n8n | Commit Build | 5m 21s | 5m 10s | 3% faster | 8.79 GB less (92.29%) |
| n8n Docker | Commit Build | 5m 7s | 3m 59s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 25s | 0m 52s | 39% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 0s | 1m 44s | 13% faster | n/a |
