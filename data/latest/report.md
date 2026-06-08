# Latest Benchmark Report

Generated: 2026-06-08 17:40 UTC

Coverage: 20 benchmarks; fresh 6/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 20s | 3m 37s | 9% slower | 44.78 MB more (6.13%) |
| OpenTelemetry Java | Warm Build | 1m 0s | 0m 54s | 10% faster | 52.36 MB less (5.85%) |
| Spring AI | Warm Build | 0m 35s | 0m 28s | 20% faster | 175.44 MB less (18.42%) |
| gRPC | Cold Build | 32m 26s | 22m 58s | 29% faster | n/a |
| Zed | Cold Build | 51m 38s | 51m 26s | near tie | 2.09 GB less (75.51%) |
| n8n | Cold Build | 5m 18s | 5m 17s | near tie | 11.94 MB more (1.65%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 56s | 3m 6s | 6% slower | 2.71 GB less (88.97%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 5m 10s | 3m 16s | 37% faster | 7.46 GB less (74.0%) |
| Mastodon | Commit Build | 3m 35s | 2m 40s | 26% faster | 9.19 GB less (90.15%) |
| Mastodon Streaming | Commit Build | 0m 13s | 0m 12s | near tie | 10.09 GB less (99.01%) |
| Discourse | Commit Build | 3m 15s | 3m 2s | 7% faster | 9.24 GB less (90.06%) |
| Discourse Base Deps | Commit Build | 0m 19s | 0m 13s | 32% faster | 9.62 GB less (93.72%) |
| Discourse Web-Only Image | Commit Build | 0m 10s | 0m 11s | near tie | 9.03 GB less (87.94%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 17s | 89% slower | 8.93 GB less (86.98%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 10s | near tie | 8.35 GB less (81.35%) |
| PostHog | Commit Build | 0m 18s | 0m 20s | near tie | n/a |
| Storybook | Commit Build | 3m 46s | 3m 22s | 11% faster | 2.43 GB less (74.99%) |
| OpenTelemetry Java | Commit Build | 1m 14s | 1m 8s | 8% faster | 2.42 GB less (73.2%) |
| Spring AI | Commit Build | 3m 20s | 3m 22s | near tie | 2.77 GB less (74.66%) |
| gRPC | Commit Build | 18m 18s | 11m 49s | 35% faster | n/a |
| Zed | Commit Build | 37m 42s | 38m 7s | near tie | 10.44 GB less (92.65%) |
| n8n | Commit Build | 4m 47s | 4m 7s | 14% faster | 12.96 GB less (94.25%) |
| n8n Docker | Commit Build | 5m 32s | 4m 27s | 20% faster | n/a |
| n8n Runners | Commit Build | 1m 25s | 0m 48s | 44% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 55s | 1m 49s | 38% faster | n/a |
