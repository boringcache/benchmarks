# Latest Benchmark Report

Generated: 2026-07-25 20:55 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 22s | 1m 24s | near tie | n/a |
| Storybook | Cold Build | 3m 16s | 3m 1s | 8% faster | 40.38 MB more (4.61%) |
| OpenTelemetry Java | Warm Build | 0m 54s | 0m 50s | near tie | 48.52 MB less (6.09%) |
| Spring AI | Cold Build | 4m 23s | 4m 31s | 3% slower | 176.76 MB less (18.73%) |
| gRPC | Cold Build | 39m 10s | 23m 36s | 40% faster | n/a |
| Zed | Cold Build | 53m 52s | 48m 36s | 10% faster | n/a |
| n8n | Cold Build | 4m 36s | 3m 58s | 14% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 29s | 2m 15s | 9% faster | 4.65 GB less (93.19%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 8m 28s | 3m 18s | 61% faster | 6.92 GB less (70.62%) |
| Mastodon | Commit Build | 3m 1s | 1m 35s | 48% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 6s | 0m 16s | 167% slower | n/a |
| Discourse | Commit Build | 5m 43s | 4m 34s | investigation only | 8.93 GB less (89.64%) |
| Discourse Base Deps | Commit Build | 0m 12s | 0m 7s | near tie | 9.11 GB less (92.84%) |
| Discourse Web-Only Image | Commit Build | 0m 12s | 0m 6s | 50% faster | 8.49 GB less (86.54%) |
| Discourse Release Image | Commit Build | 0m 17s | 0m 9s | 47% faster | 8.39 GB less (85.52%) |
| Discourse Test Image | Commit Build | 10m 34s | 6m 17s | investigation only | 9.81 GB less (83.42%) |
| PostHog | Commit Build | 26m 9s | 13m 9s | 50% faster | n/a |
| Storybook | Commit Build | 2m 48s | 3m 27s | 23% slower | 1.04 GB less (53.56%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 0m 39s | 0m 41s | near tie | 886.49 MB less (40.07%) |
| gRPC | Commit Build | 1m 15s | 0m 57s | 24% faster | n/a |
| Zed | Commit Build | 31m 14s | 30m 33s | near tie | 3.76 GB more (33.66%) |
| n8n | Commit Build | 1m 36s | 1m 40s | 4% slower | 559.84 MB less (15.82%) |
| n8n Docker | Commit Build | 5m 28s | 3m 36s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 16s | 0m 45s | 41% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 52s | 1m 10s | 38% faster | n/a |
