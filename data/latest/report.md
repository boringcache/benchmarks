# Latest Benchmark Report

Generated: 2026-07-27 13:37 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 24s | 1m 33s | 11% slower | 510.87 MB more (168.37%) |
| Storybook | Cold Build | 3m 35s | 3m 40s | near tie | n/a |
| OpenTelemetry Java | Cold Build | 11m 24s | 11m 1s | 3% faster | n/a |
| Spring AI | Warm Build | 0m 38s | 0m 30s | 21% faster | n/a |
| gRPC | Cold Build | 26m 6s | 0m 44s | 97% faster | n/a |
| Zed | Cold Build | 55m 34s | 47m 50s | 14% faster | n/a |
| n8n | Cold Build | 3m 38s | 1m 30s | 59% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 55s | 2m 39s | 9% faster | 4.89 GB less (93.51%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 3m 53s | 2m 36s | 33% faster | 6.71 GB less (69.96%) |
| Mastodon | Commit Build | 2m 32s | 1m 40s | 34% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 13s | 0m 8s | near tie | n/a |
| Discourse | Commit Build | 5m 42s | 4m 11s | investigation only | 9.88 GB less (90.54%) |
| Discourse Base Deps | Commit Build | 9m 26s | 8m 59s | investigation only | n/a |
| Discourse Web-Only Image | Commit Build | 12m 52s | 10m 35s | investigation only | n/a |
| Discourse Release Image | Commit Build | 16m 24s | 12m 4s | investigation only | n/a |
| Discourse Test Image | Commit Build | 9m 36s | 6m 33s | investigation only | n/a |
| PostHog | Commit Build | 29m 6s | 18m 3s | 38% faster | n/a |
| Storybook | Commit Build | 1m 5s | 3m 8s | 189% slower | 1.16 GB less (57.49%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 1m 13s | 1m 17s | 5% slower | 1.24 GB less (57.09%) |
| gRPC | Commit Build | 3m 3s | 0m 36s | 80% faster | n/a |
| Zed | Commit Build | 20m 1s | 20m 12s | near tie | 7.66 GB more (68.63%) |
| n8n | Commit Build | 3m 31s | 3m 22s | 4% faster | 3.21 GB less (79.42%) |
| n8n Docker | Commit Build | 4m 52s | 4m 17s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 3s | 0m 37s | 41% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 23s | 1m 15s | 48% faster | n/a |
