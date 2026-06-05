# Latest Benchmark Report

Generated: 2026-06-05 17:23 UTC

Coverage: 20 benchmarks; fresh 5/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 20s | 3m 37s | 9% slower | 44.78 MB more (6.13%) |
| OpenTelemetry Java | Warm Build | 1m 0s | 0m 54s | 10% faster | 52.36 MB less (5.85%) |
| Spring AI | Warm Build | 0m 35s | 0m 28s | 20% faster | 175.44 MB less (18.42%) |
| gRPC | Cold Build | 32m 26s | 22m 58s | 29% faster | n/a |
| Zed | Cold Build | 51m 38s | 51m 26s | near tie | 2.09 GB less (75.51%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 24s | 2m 19s | 3% faster | 3.00 GB less (89.92%) |
| Hugo Go | Commit Build | 0m 53s | 0m 52s | near tie | 1.12 GB less (80.14%) |
| Immich | Commit Build | 3m 15s | 2m 58s | 9% faster | 7.71 GB less (78.65%) |
| Mastodon | Commit Build | 2m 4s | 1m 51s | 10% faster | 8.98 GB less (89.95%) |
| Mastodon Streaming | Commit Build | 0m 10s | 0m 10s | near tie | 10.17 GB less (99.02%) |
| Discourse | Commit Build | 3m 15s | 3m 1s | 7% faster | 8.56 GB less (89.35%) |
| Discourse Base Deps | Commit Build | 0m 12s | 0m 11s | near tie | 9.61 GB less (93.71%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 8s | 47% faster | 9.02 GB less (87.93%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 12s | near tie | 8.92 GB less (86.97%) |
| Discourse Test Image | Commit Build | 0m 13s | 0m 15s | near tie | 8.34 GB less (81.33%) |
| PostHog | Commit Build | 15m 1s | 15m 7s | near tie | 3.69 GB less (37.99%) |
| Storybook | Commit Build | 3m 39s | 3m 26s | 6% faster | 2.36 GB less (74.53%) |
| OpenTelemetry Java | Commit Build | 1m 14s | 1m 8s | 8% faster | 2.42 GB less (73.2%) |
| Spring AI | Commit Build | 3m 15s | 3m 11s | near tie | 2.77 GB less (74.66%) |
| gRPC | Commit Build | 1m 4s | 0m 38s | 41% faster | n/a |
| Zed | Commit Build | 35m 55s | 37m 22s | 4% slower | 9.62 GB less (92.07%) |
| n8n | Commit Build | 5m 31s | 4m 20s | 21% faster | 5.80 GB less (88.04%) |
| n8n Docker | Commit Build | 5m 16s | 6m 58s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 57s | 0m 43s | 25% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 51s | 1m 27s | 22% faster | n/a |
