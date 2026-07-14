# Latest Benchmark Report

Generated: 2026-07-14 09:18 UTC

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
| Immich | Commit Build | 0m 19s | 0m 8s | 58% faster | 7.25 GB less (73.31%) |
| Mastodon | Commit Build | 9m 58s | 9m 11s | investigation only | 8.94 GB less (89.63%) |
| Mastodon Streaming | Commit Build | 0m 47s | 0m 26s | investigation only | 9.87 GB less (98.99%) |
| Discourse | Commit Build | 3m 47s | 3m 14s | 15% faster | 8.97 GB less (89.68%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 12s | near tie | 9.05 GB less (92.8%) |
| Discourse Web-Only Image | Commit Build | 0m 13s | 0m 16s | near tie | 8.43 GB less (86.47%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 16s | near tie | 8.33 GB less (85.45%) |
| Discourse Test Image | Commit Build | 0m 18s | 0m 14s | near tie | 7.80 GB less (80.02%) |
| PostHog | Commit Build | 20m 15s | 17m 59s | 11% faster | 2.75 GB less (28.38%) |
| Storybook | Commit Build | 3m 52s | 3m 8s | 19% faster | 5.40 GB less (86.0%) |
| OpenTelemetry Java | Commit Build | 1m 29s | 0m 57s | 36% faster | 3.14 GB less (80.42%) |
| Spring AI | Commit Build | 1m 23s | 1m 27s | 5% slower | 3.22 GB less (70.34%) |
| gRPC | Commit Build | 21m 45s | 13m 51s | 36% faster | n/a |
| Zed | Commit Build | 21m 36s | 20m 38s | 4% faster | 10.56 GB less (92.3%) |
| n8n | Commit Build | 6m 26s | 5m 35s | 13% faster | 5.95 GB less (88.47%) |
| n8n Docker | Commit Build | 5m 50s | 5m 12s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 7s | 0m 51s | 24% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 31s | 1m 52s | investigation only | n/a |
