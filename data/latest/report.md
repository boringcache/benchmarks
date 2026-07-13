# Latest Benchmark Report

Generated: 2026-07-13 13:26 UTC

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
| Immich | Commit Build | 0m 8s | 0m 11s | near tie | 7.27 GB less (73.33%) |
| Mastodon | Commit Build | 2m 54s | 1m 58s | 32% faster | 8.90 GB less (89.59%) |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 8s | near tie | 9.83 GB less (98.98%) |
| Discourse | Commit Build | 3m 34s | 2m 36s | 27% faster | 8.85 GB less (89.58%) |
| Discourse Base Deps | Commit Build | 0m 12s | 0m 10s | near tie | 9.18 GB less (92.89%) |
| Discourse Web-Only Image | Commit Build | 0m 10s | 0m 9s | near tie | 8.57 GB less (86.67%) |
| Discourse Release Image | Commit Build | 0m 15s | 0m 8s | 47% faster | 8.47 GB less (85.67%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 10s | near tie | 7.94 GB less (80.32%) |
| PostHog | Commit Build | 13m 21s | 17m 6s | 28% slower | 3.45 GB less (34.87%) |
| Storybook | Commit Build | 2m 3s | 1m 19s | 36% faster | 5.30 GB less (86.15%) |
| OpenTelemetry Java | Commit Build | 9m 16s | 9m 19s | near tie | 2.81 GB less (78.74%) |
| Spring AI | Commit Build | 1m 23s | 1m 27s | 5% slower | 3.22 GB less (70.34%) |
| gRPC | Commit Build | 15m 23s | 10m 42s | 30% faster | n/a |
| Zed | Commit Build | 44m 25s | 41m 1s | 8% faster | 10.58 GB less (92.31%) |
| n8n | Commit Build | 5m 54s | 3m 59s | 32% faster | 5.72 GB less (88.08%) |
| n8n Docker | Commit Build | 6m 26s | 4m 57s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 32s | 0m 53s | 42% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 27s | 1m 33s | 37% faster | n/a |
