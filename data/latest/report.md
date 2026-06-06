# Latest Benchmark Report

Generated: 2026-06-06 05:51 UTC

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
| Hugo | Commit Build | 3m 0s | 3m 20s | 11% slower | 3.07 GB less (90.15%) |
| Hugo Go | Commit Build | 0m 34s | 0m 30s | near tie | 1.20 GB less (81.16%) |
| Immich | Commit Build | 0m 11s | 0m 12s | near tie | 7.50 GB less (78.19%) |
| Mastodon | Commit Build | 2m 4s | 1m 51s | 10% faster | 8.98 GB less (89.95%) |
| Mastodon Streaming | Commit Build | 0m 10s | 0m 10s | near tie | 10.17 GB less (99.02%) |
| Discourse | Commit Build | 3m 8s | 3m 13s | near tie | 8.91 GB less (89.73%) |
| Discourse Base Deps | Commit Build | 0m 17s | 0m 10s | 41% faster | 9.29 GB less (93.51%) |
| Discourse Web-Only Image | Commit Build | 0m 11s | 0m 11s | near tie | 8.69 GB less (87.54%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 9s | near tie | 8.59 GB less (86.54%) |
| Discourse Test Image | Commit Build | 0m 13s | 0m 13s | near tie | 8.02 GB less (80.72%) |
| PostHog | Commit Build | 14m 25s | 11m 54s | 17% faster | 3.80 GB less (38.65%) |
| Storybook | Commit Build | 3m 46s | 3m 22s | 11% faster | 2.43 GB less (74.99%) |
| OpenTelemetry Java | Commit Build | 1m 14s | 1m 8s | 8% faster | 2.42 GB less (73.2%) |
| Spring AI | Commit Build | 3m 17s | 3m 25s | 4% slower | 2.77 GB less (74.66%) |
| gRPC | Commit Build | 1m 4s | 0m 50s | 22% faster | n/a |
| Zed | Commit Build | 41m 2s | 40m 15s | near tie | 10.48 GB less (92.68%) |
| n8n | Commit Build | 1m 59s | 1m 7s | 44% faster | 12.46 GB less (94.05%) |
| n8n Docker | Commit Build | 5m 30s | 4m 13s | 23% faster | n/a |
| n8n Runners | Commit Build | 0m 50s | 0m 43s | 14% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 38s | 1m 28s | 10% faster | n/a |
