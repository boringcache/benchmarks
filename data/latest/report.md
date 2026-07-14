# Latest Benchmark Report

Generated: 2026-07-14 13:02 UTC

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
| Immich | Commit Build | 9m 58s | 4m 54s | investigation only | 7.26 GB less (73.38%) |
| Mastodon | Commit Build | 9m 58s | 9m 11s | investigation only | 8.94 GB less (89.63%) |
| Mastodon Streaming | Commit Build | 0m 47s | 0m 26s | investigation only | 9.87 GB less (98.99%) |
| Discourse | Commit Build | 3m 15s | 2m 55s | 10% faster | 8.75 GB less (89.46%) |
| Discourse Base Deps | Commit Build | 0m 14s | 0m 14s | near tie | 9.56 GB less (93.16%) |
| Discourse Web-Only Image | Commit Build | 0m 9s | 0m 11s | near tie | 8.95 GB less (87.14%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 8s | near tie | 8.85 GB less (86.18%) |
| Discourse Test Image | Commit Build | 0m 12s | 0m 9s | near tie | 8.32 GB less (81.02%) |
| PostHog | Commit Build | 20m 31s | 18m 13s | 11% faster | 2.70 GB less (28.04%) |
| Storybook | Commit Build | 4m 21s | 3m 20s | 23% faster | 5.43 GB less (85.18%) |
| OpenTelemetry Java | Commit Build | 1m 29s | 0m 57s | 36% faster | 3.14 GB less (80.42%) |
| Spring AI | Commit Build | 3m 30s | 3m 33s | near tie | 3.22 GB less (70.39%) |
| gRPC | Commit Build | 21m 45s | 13m 51s | 36% faster | n/a |
| Zed | Commit Build | 48m 1s | 37m 12s | 23% faster | 10.57 GB less (92.3%) |
| n8n | Commit Build | 5m 8s | 4m 29s | 13% faster | 6.10 GB less (88.73%) |
| n8n Docker | Commit Build | 5m 26s | 4m 44s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 21s | 0m 55s | 32% faster | n/a |
| n8n Runners Distroless | Commit Build | 3m 3s | 1m 38s | 46% faster | n/a |
