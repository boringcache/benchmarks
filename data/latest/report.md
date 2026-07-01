# Latest Benchmark Report

Generated: 2026-07-01 09:52 UTC

Coverage: 20 benchmarks; fresh 6/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 31s | 3m 36s | near tie | 48.52 MB more (6.19%) |
| OpenTelemetry Java | Warm Build | 1m 12s | 0m 58s | 19% faster | 49.62 MB less (6.08%) |
| Spring AI | Warm Build | 0m 31s | 0m 27s | near tie | 178.93 MB less (17.92%) |
| gRPC | Cold Build | 32m 51s | 22m 36s | 31% faster | n/a |
| Zed | Cold Build | 54m 28s | 52m 9s | 4% faster | 2.11 GB less (75.65%) |
| n8n | Cold Build | 5m 18s | 5m 34s | 5% slower | 10.17 MB more (1.4%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 7s | 3m 33s | cache import unavailable | 815.05 MB less (70.09%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 0m 9s | 5m 16s | 3411% slower | 6.69 GB less (71.78%) |
| Mastodon | Commit Build | 2m 44s | 2m 1s | 26% faster | 8.94 GB less (89.73%) |
| Mastodon Streaming | Commit Build | 0m 28s | 0m 18s | 36% faster | 9.86 GB less (98.99%) |
| Discourse | Commit Build | 3m 32s | 3m 17s | 7% faster | 8.93 GB less (89.68%) |
| Discourse Base Deps | Commit Build | 0m 14s | 0m 10s | near tie | 9.26 GB less (92.95%) |
| Discourse Web-Only Image | Commit Build | 0m 9s | 0m 11s | near tie | 8.64 GB less (86.8%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 15s | near tie | 8.55 GB less (85.8%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 10s | near tie | 8.02 GB less (80.48%) |
| PostHog | Commit Build | 18m 28s | 12m 5s | 35% faster | 4.63 GB less (41.32%) |
| Storybook | Commit Build | 1m 27s | 1m 39s | 14% slower | 3.98 GB less (79.98%) |
| OpenTelemetry Java | Commit Build | 11m 10s | 7m 28s | 33% faster | 1.86 GB less (52.79%) |
| Spring AI | Commit Build | 0m 58s | 0m 49s | 16% faster | 3.18 GB less (70.67%) |
| gRPC | Commit Build | 1m 26s | 0m 40s | 53% faster | n/a |
| Zed | Commit Build | 35m 27s | 41m 31s | 17% slower | 10.55 GB less (92.52%) |
| n8n | Commit Build | 4m 59s | 4m 53s | near tie | 7.48 GB less (91.07%) |
| n8n Docker | Commit Build | 5m 47s | 5m 0s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 19s | 0m 56s | 29% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 20s | 1m 44s | 26% faster | n/a |
