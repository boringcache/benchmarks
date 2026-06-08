# Latest Benchmark Report

Generated: 2026-06-08 10:10 UTC

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
| Hugo | Commit Build | 0m 9s | 0m 10s | near tie | 2.62 GB less (88.63%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 2m 50s | 3m 8s | 11% slower | 7.87 GB less (78.98%) |
| Mastodon | Commit Build | 3m 12s | 1m 54s | 41% faster | 8.98 GB less (89.94%) |
| Mastodon Streaming | Commit Build | 0m 10s | 0m 12s | near tie | 9.88 GB less (98.99%) |
| Discourse | Commit Build | 3m 28s | 3m 28s | near tie | 8.87 GB less (89.68%) |
| Discourse Base Deps | Commit Build | 0m 16s | 0m 11s | near tie | 9.51 GB less (93.65%) |
| Discourse Web-Only Image | Commit Build | 0m 10s | 0m 11s | near tie | 8.92 GB less (87.81%) |
| Discourse Release Image | Commit Build | 0m 12s | 0m 10s | near tie | 8.82 GB less (86.84%) |
| Discourse Test Image | Commit Build | 0m 11s | 0m 8s | near tie | 8.24 GB less (81.14%) |
| PostHog | Commit Build | 6m 16s | 5m 30s | 12% faster | 3.62 GB less (36.45%) |
| Storybook | Commit Build | 3m 46s | 3m 22s | 11% faster | 2.43 GB less (74.99%) |
| OpenTelemetry Java | Commit Build | 1m 14s | 1m 8s | 8% faster | 2.42 GB less (73.2%) |
| Spring AI | Commit Build | 0m 42s | 0m 36s | 14% faster | 2.77 GB less (74.66%) |
| gRPC | Commit Build | 18m 18s | 11m 49s | 35% faster | n/a |
| Zed | Commit Build | 37m 11s | 37m 40s | near tie | 4.84 GB less (85.39%) |
| n8n | Commit Build | 4m 46s | 3m 57s | 17% faster | 12.61 GB less (94.12%) |
| n8n Docker | Commit Build | 5m 33s | 4m 31s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 38s | 0m 46s | 53% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 44s | 1m 25s | 18% faster | n/a |
