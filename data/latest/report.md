# Latest Benchmark Report

Generated: 2026-06-04 13:16 UTC

Coverage: 20 benchmarks; fresh 3/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 20s | 3m 37s | 9% slower | 44.78 MB more (6.13%) |
| OpenTelemetry Java | Warm Build | 1m 0s | 0m 54s | 10% faster | 52.36 MB less (5.85%) |
| Spring AI | Warm Build | 0m 35s | 0m 28s | 20% faster | 175.44 MB less (18.42%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 57s | 3m 1s | near tie | 1.77 GB less (84.07%) |
| Hugo Go | Commit Build | 0m 25s | 0m 28s | near tie | 944.90 MB less (76.86%) |
| Immich | Commit Build | 5m 21s | 3m 6s | 42% faster | 7.90 GB less (79.05%) |
| Mastodon | Commit Build | 3m 48s | 2m 51s | 25% faster | 9.49 GB less (90.43%) |
| Mastodon Streaming | Commit Build | 0m 30s | 0m 20s | 33% faster | 10.40 GB less (99.04%) |
| Discourse | Commit Build | 3m 10s | 2m 57s | 7% faster | 9.22 GB less (90.04%) |
| Discourse Base Deps | Commit Build | 0m 13s | 0m 12s | near tie | 9.59 GB less (93.7%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 8s | 47% faster | 9.00 GB less (87.92%) |
| Discourse Release Image | Commit Build | 0m 11s | 0m 7s | near tie | 8.90 GB less (86.95%) |
| Discourse Test Image | Commit Build | 0m 17s | 0m 8s | 53% faster | 8.33 GB less (81.3%) |
| PostHog | Commit Build | 23m 7s | 14m 24s | 38% faster | 6.53 GB less (50.87%) |
| Storybook | Commit Build | 3m 35s | 3m 36s | near tie | 2.33 GB less (74.31%) |
| OpenTelemetry Java | Commit Build | 1m 22s | 1m 10s | 15% faster | 2.38 GB less (72.87%) |
| Spring AI | Commit Build | 3m 17s | 3m 15s | near tie | 2.77 GB less (74.64%) |
| gRPC | Commit Build | 21m 34s | 13m 19s | 38% faster | n/a |
| Zed | Commit Build | 26m 55s | 26m 48s | near tie | 10.83 GB less (92.9%) |
| n8n | Commit Build | 5m 56s | 4m 35s | 23% faster | 11.57 GB less (93.67%) |
| n8n Docker | Commit Build | 5m 42s | 4m 46s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 50s | 0m 45s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 3m 3s | 1m 27s | 52% faster | n/a |
