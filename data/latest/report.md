# Latest Benchmark Report

Generated: 2026-07-07 17:21 UTC

Coverage: 20 benchmarks; fresh 5/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 31s | 3m 36s | near tie | 48.52 MB more (6.19%) |
| OpenTelemetry Java | Warm Build | 1m 1s | 0m 59s | 3% faster | 49.63 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 23s | 28% faster | 177.03 MB less (17.99%) |
| gRPC | Cold Build | 32m 56s | 23m 35s | 28% faster | n/a |
| n8n | Cold Build | 5m 41s | 5m 47s | near tie | 9.61 MB more (1.32%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 49s | 2m 44s | near tie | 1.60 GB less (82.52%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 5m 41s | 6m 7s | 8% slower | 7.27 GB less (73.35%) |
| Mastodon | Commit Build | 0m 16s | 0m 16s | near tie | 9.25 GB less (90.02%) |
| Mastodon Streaming | Commit Build | 0m 12s | 0m 9s | near tie | 9.89 GB less (98.99%) |
| Discourse | Commit Build | 3m 51s | 3m 7s | 19% faster | 9.32 GB less (90.06%) |
| Discourse Base Deps | Commit Build | 0m 16s | 0m 17s | near tie | 9.27 GB less (92.96%) |
| Discourse Web-Only Image | Commit Build | 0m 10s | 0m 11s | near tie | 8.92 GB less (87.16%) |
| Discourse Release Image | Commit Build | 0m 15s | 0m 9s | 40% faster | 8.82 GB less (86.19%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 9s | near tie | 8.29 GB less (81.02%) |
| PostHog | Commit Build | 18m 43s | 14m 20s | 23% faster | 7.54 GB less (52.46%) |
| Storybook | Commit Build | 4m 8s | 3m 28s | 16% faster | 4.74 GB less (85.3%) |
| OpenTelemetry Java | Commit Build | 9m 8s | 12m 1s | 32% slower | 3.23 GB less (81.17%) |
| Spring AI | Commit Build | 3m 33s | 3m 22s | 5% faster | 3.20 GB less (70.43%) |
| gRPC | Commit Build | 1m 26s | 0m 38s | 56% faster | n/a |
| Zed | Commit Build | 30m 9s | 38m 26s | 27% slower | 10.55 GB less (92.3%) |
| n8n | Commit Build | 2m 32s | 2m 3s | 19% faster | 10.44 GB less (93.42%) |
| n8n Docker | Commit Build | 5m 14s | 5m 12s | near tie | n/a |
| n8n Runners | Commit Build | 1m 50s | 0m 52s | 53% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 2s | 1m 52s | 8% faster | n/a |
