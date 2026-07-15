# Latest Benchmark Report

Generated: 2026-07-15 13:02 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 10s | 18% faster | 36.28 MB less (11.96%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 29s | 10m 55s | 5% faster | 49.73 MB less (6.09%) |
| Spring AI | Warm Build | 0m 34s | 0m 27s | 21% faster | 176.12 MB less (17.96%) |
| gRPC | Cold Build | 25m 0s | 24m 40s | near tie | n/a |
| Zed | Warm Build | 20m 40s | 19m 17s | 7% faster | 2.13 GB less (78.15%) |
| n8n | Warm Build | 1m 28s | 0m 57s | 35% faster | 7.61 MB more (0.99%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 18s | 2m 27s | 26% faster | 1.18 GB less (77.73%) |
| Hugo Go | Commit Build | 1m 39s | 0m 50s | 49% faster | 1.01 GB less (79.5%) |
| Immich | Commit Build | 0m 8s | 7m 44s | cache import unavailable | 7.21 GB less (73.19%) |
| Mastodon | Commit Build | 3m 41s | 2m 58s | 19% faster | 8.94 GB less (89.64%) |
| Mastodon Streaming | Commit Build | 0m 17s | 0m 23s | 35% slower | 9.88 GB less (98.99%) |
| Discourse | Commit Build | 2m 58s | 3m 5s | 4% slower | 8.73 GB less (89.43%) |
| Discourse Base Deps | Commit Build | 0m 15s | 0m 11s | near tie | 9.44 GB less (93.07%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 11s | near tie | 8.82 GB less (86.98%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 9s | near tie | 8.72 GB less (86.0%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 13s | near tie | 8.19 GB less (80.78%) |
| PostHog | Commit Build | 32m 18s | 21m 11s | 34% faster | 4.54 GB less (39.31%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 44s | 1m 3s | 39% faster | 3.14 GB less (80.5%) |
| Spring AI | Commit Build | 1m 54s | 1m 55s | near tie | 3.22 GB less (70.36%) |
| gRPC | Commit Build | 2m 49s | 0m 39s | 77% faster | n/a |
| Zed | Commit Build | 40m 50s | 40m 53s | near tie | 10.57 GB less (92.3%) |
| n8n | Commit Build | 4m 0s | 3m 3s | 24% faster | 13.66 GB less (94.61%) |
| n8n Docker | Commit Build | 5m 54s | 5m 15s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 38s | 0m 58s | 41% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 1s | 1m 40s | 17% faster | n/a |
