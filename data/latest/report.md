# Latest Benchmark Report

Generated: 2026-07-26 09:20 UTC

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
| Discourse | Commit Build | 7m 35s | 4m 36s | investigation only | 8.97 GB less (89.67%) |
| Discourse Base Deps | Commit Build | 5m 33s | 4m 52s | 12% faster | 9.30 GB less (92.98%) |
| Discourse Web-Only Image | Commit Build | 9m 58s | 5m 29s | 45% faster | 8.68 GB less (86.79%) |
| Discourse Release Image | Commit Build | 11m 27s | 7m 54s | 31% faster | 12.60 GB less (89.87%) |
| Discourse Test Image | Commit Build | 10m 4s | 6m 36s | investigation only | 8.05 GB less (80.49%) |
| PostHog | Commit Build | 0m 19s | 0m 23s | near tie | n/a |
| Storybook | Commit Build | 2m 48s | 3m 27s | 23% slower | 1.04 GB less (53.56%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 0m 39s | 0m 41s | near tie | 886.49 MB less (40.07%) |
| gRPC | Commit Build | 1m 15s | 0m 57s | 24% faster | n/a |
| Zed | Commit Build | 47m 35s | 45m 21s | 5% faster | 5.41 GB more (48.35%) |
| n8n | Commit Build | 3m 34s | 3m 35s | near tie | 568.62 MB less (15.84%) |
| n8n Docker | Commit Build | 5m 8s | 3m 4s | 40% faster | n/a |
| n8n Runners | Commit Build | 1m 14s | 0m 43s | 42% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 58s | 1m 28s | 25% faster | n/a |
