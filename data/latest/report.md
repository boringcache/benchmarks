# Latest Benchmark Report

Generated: 2026-07-12 12:52 UTC

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
| n8n | Warm Build | 1m 28s | 0m 57s | 35% faster | 7.61 MB more (0.99%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 17s | 0m 7s | 59% faster | 1.59 GB less (82.4%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 0m 8s | 0m 11s | near tie | 7.27 GB less (73.33%) |
| Mastodon | Commit Build | 2m 10s | 1m 54s | 12% faster | 8.96 GB less (89.65%) |
| Mastodon Streaming | Commit Build | 0m 6s | 0m 8s | near tie | 10.31 GB less (99.03%) |
| Discourse | Commit Build | 5m 52s | 4m 29s | investigation only | 8.88 GB less (89.61%) |
| Discourse Base Deps | Commit Build | 8m 30s | 7m 4s | investigation only | 9.14 GB less (92.87%) |
| Discourse Web-Only Image | Commit Build | 10m 49s | 9m 32s | investigation only | 10.75 GB less (89.08%) |
| Discourse Release Image | Commit Build | 12m 58s | 11m 12s | investigation only | 10.65 GB less (88.26%) |
| Discourse Test Image | Commit Build | 8m 0s | 7m 22s | investigation only | 7.88 GB less (80.07%) |
| PostHog | Commit Build | 0m 20s | 0m 15s | near tie | 3.46 GB less (34.9%) |
| Storybook | Commit Build | 3m 42s | 2m 51s | 23% faster | 5.21 GB less (86.09%) |
| OpenTelemetry Java | Commit Build | 9m 16s | 9m 19s | near tie | 2.81 GB less (78.74%) |
| Spring AI | Commit Build | 3m 55s | 2m 45s | 30% faster | 3.22 GB less (70.34%) |
| gRPC | Commit Build | 6m 59s | 4m 42s | 33% faster | n/a |
| Zed | Commit Build | 45m 39s | 45m 13s | near tie | 10.55 GB less (92.29%) |
| n8n | Commit Build | 5m 8s | 4m 28s | 13% faster | 11.90 GB less (93.89%) |
| n8n Docker | Commit Build | 5m 12s | 4m 42s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 55s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 1m 46s | 1m 38s | 8% faster | n/a |
