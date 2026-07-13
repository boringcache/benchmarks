# Latest Benchmark Report

Generated: 2026-07-13 20:52 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 10s | 18% faster | 36.28 MB less (11.96%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 29s | 10m 55s | 5% faster | 49.73 MB less (6.09%) |
| Spring AI | Warm Build | 0m 34s | 0m 27s | 21% faster | 176.12 MB less (17.96%) |
| gRPC | Cold Build | 25m 0s | 24m 40s | near tie | n/a |
| Zed | Warm Build | 20m 40s | 19m 17s | 7% faster | 2.13 GB less (78.15%) |
| n8n | Warm Build | 1m 28s | 0m 57s | 35% faster | 7.61 MB more (0.99%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 18s | 2m 27s | 26% faster | 1.18 GB less (77.73%) |
| Hugo Go | Commit Build | 1m 39s | 0m 50s | 49% faster | 1.01 GB less (79.5%) |
| Immich | Commit Build | 3m 24s | 3m 19s | near tie | 6.72 GB less (71.8%) |
| Mastodon | Commit Build | 3m 34s | 2m 56s | 18% faster | 8.95 GB less (89.65%) |
| Mastodon Streaming | Commit Build | 0m 9s | 0m 21s | 133% slower | 9.88 GB less (98.99%) |
| Discourse | Commit Build | 3m 35s | 3m 9s | 12% faster | 8.88 GB less (89.6%) |
| Discourse Base Deps | Commit Build | 0m 12s | 0m 12s | near tie | 9.26 GB less (92.95%) |
| Discourse Web-Only Image | Commit Build | 0m 17s | 0m 9s | 47% faster | 8.65 GB less (86.78%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 10s | near tie | 8.55 GB less (85.79%) |
| Discourse Test Image | Commit Build | 0m 12s | 0m 19s | 58% slower | 8.02 GB less (80.48%) |
| PostHog | Commit Build | 27m 32s | 18m 17s | 34% faster | 3.30 GB less (32.27%) |
| Storybook | Commit Build | 3m 52s | 3m 8s | 19% faster | 5.40 GB less (86.0%) |
| OpenTelemetry Java | Commit Build | 7m 15s | 8m 7s | 12% slower | 2.79 GB less (78.63%) |
| Spring AI | Commit Build | 1m 23s | 1m 27s | 5% slower | 3.22 GB less (70.34%) |
| gRPC | Commit Build | 5m 8s | 3m 7s | 39% faster | n/a |
| Zed | Commit Build | 32m 35s | 31m 28s | 3% faster | 10.58 GB less (92.31%) |
| n8n | Commit Build | 4m 52s | 4m 54s | near tie | 12.47 GB less (94.15%) |
| n8n Docker | Commit Build | 6m 0s | 4m 36s | 23% faster | n/a |
| n8n Runners | Commit Build | 1m 43s | 0m 57s | 45% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 1s | 1m 37s | 20% faster | n/a |
