# Latest Benchmark Report

Generated: 2026-07-27 09:55 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 24s | 1m 25s | near tie | n/a |
| Storybook | Cold Build | 3m 35s | 3m 40s | near tie | n/a |
| OpenTelemetry Java | Warm Build | 1m 3s | 0m 59s | 6% faster | n/a |
| Spring AI | Warm Build | 0m 38s | 0m 30s | 21% faster | n/a |
| gRPC | Cold Build | 32m 18s | 24m 3s | 26% faster | n/a |
| Zed | Cold Build | 55m 31s | 53m 36s | 3% faster | 619.90 MB less (22.18%) |
| n8n | Warm Build | 1m 28s | 1m 7s | 24% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 55s | 2m 39s | 9% faster | 4.89 GB less (93.51%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 3m 53s | 2m 36s | 33% faster | 6.71 GB less (69.96%) |
| Mastodon | Commit Build | 2m 35s | 1m 39s | 36% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 10s | 0m 10s | near tie | n/a |
| Discourse | Commit Build | 5m 42s | 4m 11s | investigation only | 9.88 GB less (90.54%) |
| Discourse Base Deps | Commit Build | 1m 33s | 0m 52s | 44% faster | 9.27 GB less (92.96%) |
| Discourse Web-Only Image | Commit Build | 5m 42s | 3m 0s | 47% faster | 9.59 GB less (87.89%) |
| Discourse Release Image | Commit Build | 5m 32s | 3m 50s | 31% faster | 9.49 GB less (86.98%) |
| Discourse Test Image | Commit Build | 8m 53s | 6m 59s | investigation only | 8.96 GB less (82.12%) |
| PostHog | Commit Build | 20m 55s | 14m 9s | 32% faster | n/a |
| Storybook | Commit Build | 1m 19s | 1m 24s | 6% slower | 1.07 GB less (54.13%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 0m 43s | 0m 47s | near tie | 887.75 MB less (40.08%) |
| gRPC | Commit Build | 8m 54s | 5m 16s | 41% faster | n/a |
| Zed | Commit Build | 20m 1s | 20m 12s | near tie | 7.66 GB more (68.63%) |
| n8n | Commit Build | 3m 39s | 3m 48s | 4% slower | 824.84 MB less (21.32%) |
| n8n Docker | Commit Build | 5m 36s | 3m 37s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 42s | 22% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 12s | 1m 18s | 41% faster | n/a |
