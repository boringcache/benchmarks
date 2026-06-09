# Latest Benchmark Report

Generated: 2026-06-09 01:30 UTC

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
| Immich | Commit Build | 0m 13s | 0m 38s | 192% slower | 7.29 GB less (73.56%) |
| Mastodon | Commit Build | 3m 35s | 2m 40s | 26% faster | 9.19 GB less (90.15%) |
| Mastodon Streaming | Commit Build | 0m 13s | 0m 12s | near tie | 10.09 GB less (99.01%) |
| Discourse | Commit Build | 3m 50s | 3m 2s | 21% faster | 8.90 GB less (89.72%) |
| Discourse Base Deps | Commit Build | 0m 12s | 0m 12s | near tie | 9.28 GB less (93.5%) |
| Discourse Web-Only Image | Commit Build | 0m 11s | 0m 14s | near tie | 8.69 GB less (87.53%) |
| Discourse Release Image | Commit Build | 0m 15s | 0m 12s | near tie | 8.59 GB less (86.53%) |
| Discourse Test Image | Commit Build | 0m 13s | 0m 10s | near tie | 8.01 GB less (80.71%) |
| PostHog | Commit Build | 13m 50s | 13m 22s | 3% faster | n/a |
| Storybook | Commit Build | 3m 46s | 3m 22s | 11% faster | 2.43 GB less (74.99%) |
| OpenTelemetry Java | Commit Build | 1m 14s | 1m 8s | 8% faster | 2.42 GB less (73.2%) |
| Spring AI | Commit Build | 1m 52s | 1m 38s | 13% faster | 2.77 GB less (74.66%) |
| gRPC | Commit Build | 16m 0s | 11m 0s | 31% faster | n/a |
| Zed | Commit Build | 37m 42s | 38m 7s | near tie | 10.44 GB less (92.65%) |
| n8n | Commit Build | 3m 21s | 2m 17s | 32% faster | 13.12 GB less (94.31%) |
| n8n Docker | Commit Build | 5m 2s | 4m 45s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 58s | 0m 49s | 16% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 51s | 1m 33s | 16% faster | n/a |
