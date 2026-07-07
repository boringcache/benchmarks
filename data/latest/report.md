# Latest Benchmark Report

Generated: 2026-07-07 05:59 UTC

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
| Hugo | Commit Build | 2m 49s | 2m 44s | near tie | 1.60 GB less (82.52%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 0m 8s | 0m 15s | 88% slower | 7.28 GB less (73.42%) |
| Mastodon | Commit Build | 0m 16s | 0m 16s | near tie | 9.25 GB less (90.02%) |
| Mastodon Streaming | Commit Build | 0m 12s | 0m 9s | near tie | 9.89 GB less (98.99%) |
| Discourse | Commit Build | 3m 59s | 2m 59s | 25% faster | 8.90 GB less (89.64%) |
| Discourse Base Deps | Commit Build | 0m 10s | 0m 11s | near tie | 9.22 GB less (92.92%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 12s | near tie | 8.61 GB less (86.75%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 10s | 38% faster | 8.51 GB less (85.75%) |
| Discourse Test Image | Commit Build | 0m 10s | 0m 11s | near tie | 7.98 GB less (80.43%) |
| PostHog | Commit Build | 13m 45s | 12m 29s | 9% faster | 3.10 GB less (31.17%) |
| Storybook | Commit Build | 3m 46s | 3m 19s | 12% faster | 4.31 GB less (80.93%) |
| OpenTelemetry Java | Commit Build | 9m 8s | 12m 1s | 32% slower | 3.23 GB less (81.17%) |
| Spring AI | Commit Build | 1m 19s | 1m 8s | 14% faster | 3.19 GB less (70.34%) |
| gRPC | Commit Build | 1m 41s | 0m 37s | 63% faster | n/a |
| Zed | Commit Build | 19m 6s | 19m 9s | near tie | 10.47 GB less (92.4%) |
| n8n | Commit Build | 3m 51s | 3m 11s | 17% faster | 9.88 GB less (93.07%) |
| n8n Docker | Commit Build | 5m 41s | 4m 46s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 8s | 0m 56s | 18% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 17s | 1m 34s | 31% faster | n/a |
