# Latest Benchmark Report

Generated: 2026-06-01 10:32 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 16s | 3m 21s | near tie | 1.50 GB less (81.67%) |
| Hugo Go | Cold Build | 1m 17s | 1m 21s | 5% slower | 44.20 MB less (14.84%) |
| Immich | Cold Build | 5m 49s | 4m 50s | 17% faster | 7.82 GB less (79.02%) |
| Mastodon | Warm Build | 0m 12s | 0m 10s | near tie | 9.60 GB less (90.4%) |
| Mastodon Streaming | Warm Build | 0m 13s | 0m 7s | 46% faster | 9.92 GB less (98.99%) |
| Discourse | Cold Build | 7m 11s | 5m 29s | 24% faster | 8.94 GB less (89.76%) |
| Discourse Base Deps | Cold Build | 5m 47s | 4m 9s | 28% faster | 9.38 GB less (93.57%) |
| Discourse Web-Only Image | Cold Build | 8m 50s | 6m 50s | 23% faster | 8.76 GB less (87.38%) |
| Discourse Release Image | Warm Build | 0m 9s | 0m 7s | near tie | 12.14 GB less (89.9%) |
| Discourse Test Image | Cold Build | 9m 11s | 7m 12s | 22% faster | 8.08 GB less (80.62%) |
| PostHog | Warm Build | 0m 16s | 0m 11s | near tie | 8.28 GB less (56.27%) |
| Storybook | Cold Build | 3m 45s | 3m 31s | 6% faster | 44.74 MB more (6.12%) |
| OpenTelemetry Java | Cold Build | 11m 16s | 9m 23s | 17% faster | 51.51 MB less (5.76%) |
| Spring AI | Warm Build | 0m 31s | 0m 26s | near tie | 177.30 MB less (18.59%) |
| gRPC | Cold Build | 32m 7s | 22m 43s | 29% faster | n/a |
| Zed | Cold Build | 54m 55s | 51m 33s | 6% faster | 2.15 GB less (74.81%) |
| n8n | Cold Build | 5m 1s | 5m 18s | 6% slower | 13.62 MB more (1.9%) |
| n8n Docker | Warm Build | 1m 57s | 1m 53s | 3% faster | n/a |
| n8n Runners | Warm Build | 0m 33s | 0m 28s | near tie | n/a |
| n8n Runners Distroless | Cold Build | 1m 43s | 1m 38s | 5% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 4s | 2m 41s | 13% faster | 2.54 GB less (88.34%) |
| Hugo Go | Commit Build | 0m 30s | 0m 23s | 23% faster | 1.33 GB less (82.74%) |
| Immich | Commit Build | 0m 15s | 0m 8s | 47% faster | 7.56 GB less (78.42%) |
| Mastodon | Commit Build | 3m 54s | 0m 18s | 92% faster | 8.97 GB less (89.79%) |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 9s | near tie | 9.87 GB less (98.99%) |
| Discourse | Commit Build | 3m 8s | 3m 5s | near tie | 8.62 GB less (89.42%) |
| Discourse Base Deps | Commit Build | 0m 16s | 0m 7s | 56% faster | 8.99 GB less (93.31%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 10s | near tie | 8.37 GB less (86.88%) |
| Discourse Release Image | Commit Build | 0m 13s | 0m 7s | 46% faster | 8.27 GB less (85.85%) |
| Discourse Test Image | Commit Build | 0m 19s | 0m 10s | 47% faster | 7.69 GB less (79.85%) |
| PostHog | Commit Build | 13m 27s | 11m 55s | 11% faster | 3.47 GB less (36.67%) |
| Storybook | Commit Build | 3m 26s | 3m 29s | near tie | 2.05 GB less (72.3%) |
| OpenTelemetry Java | Commit Build | 5m 21s | 4m 44s | 12% faster | 3.12 GB less (77.86%) |
| Spring AI | Commit Build | 3m 19s | 3m 17s | near tie | 2.70 GB less (75.54%) |
| gRPC | Commit Build | 1m 17s | 1m 31s | 18% slower | n/a |
| Zed | Commit Build | 40m 36s | 40m 35s | near tie | 10.77 GB less (93.28%) |
| n8n | Commit Build | 5m 32s | 5m 1s | 9% faster | 4.38 GB less (85.03%) |
| n8n Docker | Commit Build | 3m 48s | 3m 31s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 27s | 0m 51s | 41% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 6s | 1m 22s | 35% faster | n/a |
