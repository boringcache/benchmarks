# Latest Benchmark Report

Generated: 2026-07-27 05:55 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 24s | 1m 25s | near tie | n/a |
| Storybook | Cold Build | 3m 16s | 3m 1s | 8% faster | 40.38 MB more (4.61%) |
| OpenTelemetry Java | Warm Build | 0m 54s | 0m 50s | near tie | 48.52 MB less (6.09%) |
| Spring AI | Cold Build | 4m 23s | 4m 31s | 3% slower | 176.76 MB less (18.73%) |
| gRPC | Cold Build | 39m 10s | 23m 36s | 40% faster | n/a |
| Zed | Cold Build | 53m 52s | 48m 36s | 10% faster | n/a |
| n8n | Cold Build | 4m 2s | 3m 58s | near tie | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 55s | 2m 39s | 9% faster | 4.89 GB less (93.51%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 3m 53s | 2m 36s | 33% faster | 6.71 GB less (69.96%) |
| Mastodon | Commit Build | 3m 1s | 1m 35s | 48% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 6s | 0m 16s | 167% slower | n/a |
| Discourse | Commit Build | 3m 34s | 2m 48s | 21% faster | 8.85 GB less (89.55%) |
| Discourse Base Deps | Commit Build | 9m 39s | 7m 41s | investigation only | n/a |
| Discourse Web-Only Image | Commit Build | 10m 3s | 10m 17s | investigation only | n/a |
| Discourse Release Image | Commit Build | 14m 28s | 11m 41s | investigation only | n/a |
| Discourse Test Image | Commit Build | 7m 54s | 6m 32s | investigation only | n/a |
| PostHog | Commit Build | 0m 29s | 0m 20s | 31% faster | n/a |
| Storybook | Commit Build | 2m 48s | 3m 27s | 23% slower | 1.04 GB less (53.56%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 0m 39s | 0m 41s | near tie | 886.49 MB less (40.07%) |
| gRPC | Commit Build | 1m 15s | 0m 57s | 24% faster | n/a |
| Zed | Commit Build | 45m 20s | 33m 4s | 27% faster | 7.68 GB more (68.89%) |
| n8n | Commit Build | 1m 17s | 1m 10s | 9% faster | 700.69 MB less (18.79%) |
| n8n Docker | Commit Build | 5m 9s | 3m 34s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 13s | 0m 43s | 41% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 55s | 1m 21s | 30% faster | n/a |
