# Latest Benchmark Report

Generated: 2026-07-02 20:55 UTC

Coverage: 20 benchmarks; fresh 6/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 31s | 3m 36s | near tie | 48.52 MB more (6.19%) |
| OpenTelemetry Java | Warm Build | 1m 1s | 0m 59s | 3% faster | 49.63 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 23s | 28% faster | 177.03 MB less (17.99%) |
| gRPC | Cold Build | 32m 51s | 22m 36s | 31% faster | n/a |
| Zed | Cold Build | 54m 28s | 52m 9s | 4% faster | 2.11 GB less (75.65%) |
| n8n | Cold Build | 5m 18s | 5m 34s | 5% slower | 10.17 MB more (1.4%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 7s | 3m 33s | cache import unavailable | 815.05 MB less (70.09%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 3m 37s | 3m 4s | 15% faster | 6.69 GB less (71.75%) |
| Mastodon | Commit Build | 2m 9s | 1m 56s | 10% faster | 8.97 GB less (89.77%) |
| Mastodon Streaming | Commit Build | 0m 23s | 0m 7s | 70% faster | 9.89 GB less (98.99%) |
| Discourse | Commit Build | 3m 35s | 3m 10s | 12% faster | 8.84 GB less (89.59%) |
| Discourse Base Deps | Commit Build | 0m 15s | 0m 12s | near tie | 9.25 GB less (92.94%) |
| Discourse Web-Only Image | Commit Build | 0m 11s | 0m 20s | 82% slower | 8.64 GB less (86.79%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 19s | near tie | 8.54 GB less (85.79%) |
| Discourse Test Image | Commit Build | 0m 19s | 0m 10s | 47% faster | 8.01 GB less (80.48%) |
| PostHog | Commit Build | 17m 41s | 14m 9s | 20% faster | 3.73 GB less (35.31%) |
| Storybook | Commit Build | 3m 49s | 3m 29s | 9% faster | 4.23 GB less (80.8%) |
| OpenTelemetry Java | Commit Build | 1m 48s | 1m 51s | near tie | 2.34 GB less (58.43%) |
| Spring AI | Commit Build | 2m 2s | 2m 7s | 4% slower | 3.19 GB less (70.59%) |
| gRPC | Commit Build | 1m 34s | 0m 36s | 62% faster | n/a |
| Zed | Commit Build | 35m 27s | 41m 31s | 17% slower | 10.55 GB less (92.52%) |
| n8n | Commit Build | 2m 42s | 2m 28s | 9% faster | 8.63 GB less (92.16%) |
| n8n Docker | Commit Build | 5m 7s | 3m 59s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 25s | 0m 52s | 39% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 0s | 1m 44s | 13% faster | n/a |
