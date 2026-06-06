# Latest Benchmark Report

Generated: 2026-06-06 16:55 UTC

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
| Discourse | Commit Build | 5m 28s | 5m 12s | investigation only | 10.06 GB less (90.79%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 13s | near tie | 9.14 GB less (93.41%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 17s | 113% slower | 8.55 GB less (87.35%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 10s | near tie | 8.45 GB less (86.34%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 12s | near tie | 7.87 GB less (80.43%) |
| PostHog | Commit Build | 12m 31s | 11m 7s | 11% faster | 3.92 GB less (39.42%) |
| Storybook | Commit Build | 3m 46s | 3m 22s | 11% faster | 2.43 GB less (74.99%) |
| OpenTelemetry Java | Commit Build | 1m 14s | 1m 8s | 8% faster | 2.42 GB less (73.2%) |
| Spring AI | Commit Build | 0m 42s | 0m 32s | 24% faster | 2.77 GB less (74.66%) |
| gRPC | Commit Build | 1m 4s | 0m 50s | 22% faster | n/a |
| Zed | Commit Build | 19m 20s | 18m 51s | near tie | 4.82 GB less (85.34%) |
| n8n | Commit Build | 4m 15s | 3m 14s | 24% faster | 12.56 GB less (94.1%) |
| n8n Docker | Commit Build | 5m 33s | 4m 31s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 38s | 0m 46s | 53% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 44s | 1m 25s | 18% faster | n/a |
