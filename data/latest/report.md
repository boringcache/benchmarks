# Latest Benchmark Report

Generated: 2026-06-08 14:03 UTC

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
| Hugo | Commit Build | 3m 15s | 3m 0s | 8% faster | 2.63 GB less (88.68%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 8m 58s | 5m 27s | 39% faster | 7.46 GB less (74.0%) |
| Mastodon | Commit Build | 2m 49s | 2m 1s | 28% faster | 9.19 GB less (90.15%) |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 19s | 73% slower | 10.09 GB less (99.01%) |
| Discourse | Commit Build | 3m 10s | 3m 1s | 5% faster | 8.90 GB less (89.71%) |
| Discourse Base Deps | Commit Build | 0m 10s | 0m 12s | near tie | 9.58 GB less (93.69%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 11s | near tie | 8.98 GB less (87.89%) |
| Discourse Release Image | Commit Build | 0m 14s | 0m 13s | near tie | 8.88 GB less (86.92%) |
| Discourse Test Image | Commit Build | 0m 10s | 0m 15s | near tie | 8.31 GB less (81.27%) |
| PostHog | Commit Build | 0m 18s | 0m 20s | near tie | n/a |
| Storybook | Commit Build | 3m 46s | 3m 22s | 11% faster | 2.43 GB less (74.99%) |
| OpenTelemetry Java | Commit Build | 1m 14s | 1m 8s | 8% faster | 2.42 GB less (73.2%) |
| Spring AI | Commit Build | 0m 47s | 0m 34s | 28% faster | 2.77 GB less (74.66%) |
| gRPC | Commit Build | 18m 18s | 11m 49s | 35% faster | n/a |
| Zed | Commit Build | 37m 42s | 38m 7s | near tie | 10.44 GB less (92.65%) |
| n8n | Commit Build | 6m 27s | 5m 22s | 17% faster | 12.77 GB less (94.17%) |
| n8n Docker | Commit Build | 4m 58s | 5m 18s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 44s | 0m 43s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 2m 21s | 1m 33s | 34% faster | n/a |
