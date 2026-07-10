# Latest Benchmark Report

Generated: 2026-07-10 17:13 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 22s | 4% faster | 36.28 MB less (11.96%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 29s | 10m 55s | 5% faster | 49.73 MB less (6.09%) |
| Spring AI | Warm Build | 0m 34s | 0m 27s | 21% faster | 176.12 MB less (17.96%) |
| gRPC | Cold Build | 25m 0s | 24m 40s | near tie | n/a |
| Zed | Warm Build | 20m 40s | 19m 17s | 7% faster | 2.13 GB less (78.15%) |
| n8n | Cold Build | 5m 27s | 5m 42s | 5% slower | 7.54 MB more (1.03%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 17s | 0m 7s | 59% faster | 1.59 GB less (82.4%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 3m 36s | 2m 43s | 25% faster | 7.29 GB less (73.38%) |
| Mastodon | Commit Build | 2m 10s | 1m 54s | 12% faster | 8.96 GB less (89.65%) |
| Mastodon Streaming | Commit Build | 0m 6s | 0m 8s | near tie | 10.31 GB less (99.03%) |
| Discourse | Commit Build | 3m 12s | 3m 8s | near tie | 8.92 GB less (89.66%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 12s | near tie | 9.25 GB less (92.94%) |
| Discourse Web-Only Image | Commit Build | 0m 20s | 0m 12s | 40% faster | 8.63 GB less (86.77%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 14s | near tie | 8.53 GB less (85.78%) |
| Discourse Test Image | Commit Build | 0m 12s | 0m 9s | near tie | 8.01 GB less (80.46%) |
| PostHog | Commit Build | 18m 36s | 12m 21s | 34% faster | 3.05 GB less (31.09%) |
| Storybook | Commit Build | 3m 42s | 2m 51s | 23% faster | 5.21 GB less (86.09%) |
| OpenTelemetry Java | Commit Build | 8m 20s | 8m 2s | 4% faster | 2.67 GB less (77.9%) |
| Spring AI | Commit Build | 0m 40s | 0m 28s | 30% faster | 3.22 GB less (70.34%) |
| gRPC | Commit Build | 7m 45s | 5m 27s | 30% faster | n/a |
| Zed | Commit Build | 28m 11s | 27m 43s | near tie | 10.58 GB less (92.31%) |
| n8n | Commit Build | 3m 26s | 2m 33s | 26% faster | 11.76 GB less (93.82%) |
| n8n Docker | Commit Build | 5m 33s | 6m 3s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 8s | 0m 57s | 16% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 10s | 1m 25s | 35% faster | n/a |
