# Latest Benchmark Report

Generated: 2026-07-22 13:10 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 21s | 1m 20s | near tie | 36.20 MB less (11.94%) |
| Storybook | Cold Build | 3m 16s | 3m 1s | 8% faster | 40.38 MB more (4.61%) |
| OpenTelemetry Java | Warm Build | 0m 54s | 0m 50s | near tie | 48.52 MB less (6.09%) |
| Spring AI | Cold Build | 4m 23s | 4m 31s | 3% slower | 176.76 MB less (18.73%) |
| gRPC | Cold Build | 37m 41s | 18m 14s | 52% faster | n/a |
| Zed | Cold Build | 55m 30s | 54m 13s | near tie | 2.12 GB less (78.07%) |
| n8n | Cold Build | 3m 43s | 3m 43s | near tie | 7.54 MB more (0.97%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 11s | 0m 8s | near tie | 119.70 MB less (25.62%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 4m 43s | 4m 41s | near tie | 6.59 GB less (69.58%) |
| Mastodon | Commit Build | 2m 17s | 1m 56s | 15% faster | 8.66 GB less (89.33%) |
| Mastodon Streaming | Commit Build | 0m 20s | 0m 18s | near tie | 9.59 GB less (98.96%) |
| Discourse | Commit Build | 3m 15s | 3m 14s | near tie | 8.51 GB less (89.18%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 8s | near tie | 8.84 GB less (92.64%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 8s | 47% faster | 8.14 GB less (85.29%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 11s | near tie | 8.04 GB less (84.25%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 10s | near tie | 7.59 GB less (79.55%) |
| PostHog | Commit Build | 28m 3s | 21m 59s | 22% faster | 2.60 GB less (26.69%) |
| Storybook | Commit Build | 1m 23s | 0m 51s | 39% faster | 5.64 GB less (86.28%) |
| OpenTelemetry Java | Commit Build | 1m 25s | 1m 4s | 25% faster | 2.94 GB less (80.1%) |
| Spring AI | Commit Build | 0m 48s | 0m 31s | 35% faster | 3.27 GB less (70.22%) |
| gRPC | Commit Build | 2m 15s | 1m 29s | 34% faster | n/a |
| Zed | Commit Build | 43m 29s | 42m 54s | near tie | 10.59 GB less (92.16%) |
| n8n | Commit Build | 3m 19s | 2m 22s | 29% faster | 2.97 GB less (79.02%) |
| n8n Docker | Commit Build | 4m 55s | 4m 51s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 55s | 0m 54s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 1m 45s | 1m 36s | 9% faster | n/a |
