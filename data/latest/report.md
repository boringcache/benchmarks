# Latest Benchmark Report

Generated: 2026-07-23 20:53 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 22s | 1m 24s | near tie | n/a |
| Storybook | Cold Build | 3m 16s | 3m 1s | 8% faster | 40.38 MB more (4.61%) |
| OpenTelemetry Java | Warm Build | 0m 54s | 0m 50s | near tie | 48.52 MB less (6.09%) |
| Spring AI | Cold Build | 4m 23s | 4m 31s | 3% slower | 176.76 MB less (18.73%) |
| gRPC | Cold Build | 39m 10s | 23m 36s | 40% faster | n/a |
| Zed | Cold Build | 53m 52s | 48m 36s | 10% faster | n/a |
| n8n | Cold Build | 4m 36s | 3m 58s | 14% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 16s | 2m 19s | 29% faster | 1.94 GB less (85.13%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 0m 28s | 0m 10s | 64% faster | 6.58 GB less (69.57%) |
| Mastodon | Commit Build | 0m 22s | 0m 15s | 32% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 13s | 0m 12s | near tie | n/a |
| Discourse | Commit Build | 4m 52s | 2m 48s | 42% faster | 8.97 GB less (89.67%) |
| Discourse Base Deps | Commit Build | 0m 19s | 0m 10s | 47% faster | 9.30 GB less (92.98%) |
| Discourse Web-Only Image | Commit Build | 0m 24s | 0m 11s | 54% faster | 8.68 GB less (86.79%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 6s | near tie | 8.58 GB less (85.8%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 8s | near tie | 8.05 GB less (80.49%) |
| PostHog | Commit Build | 20m 42s | 13m 52s | 33% faster | n/a |
| Storybook | Commit Build | 0m 51s | 1m 11s | 39% slower | 908.18 MB less (49.76%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 4m 18s | 4m 19s | near tie | 205.07 MB more (21.74%) |
| gRPC | Commit Build | 6m 52s | 4m 9s | 40% faster | n/a |
| Zed | Commit Build | 33m 20s | 34m 32s | 4% slower | 2.11 GB less (35.09%) |
| n8n | Commit Build | 3m 37s | 3m 52s | 7% slower | 516.42 MB more (20.06%) |
| n8n Docker | Commit Build | 5m 54s | 3m 42s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 3s | 0m 43s | 32% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 18s | 1m 9s | 50% faster | n/a |
