# Latest Benchmark Report

Generated: 2026-07-25 01:12 UTC

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
| Hugo | Commit Build | 3m 16s | 2m 19s | 29% faster | 1.94 GB less (85.13%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 8m 28s | 3m 18s | 61% faster | 6.92 GB less (70.62%) |
| Mastodon | Commit Build | 3m 1s | 1m 35s | 48% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 6s | 0m 16s | 167% slower | n/a |
| Discourse | Commit Build | 4m 4s | 2m 42s | 34% faster | 8.78 GB less (89.47%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 7s | near tie | 9.11 GB less (92.84%) |
| Discourse Web-Only Image | Commit Build | 0m 21s | 0m 10s | 52% faster | 8.49 GB less (86.54%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 16s | 100% slower | 8.39 GB less (85.52%) |
| Discourse Test Image | Commit Build | 0m 12s | 0m 24s | 100% slower | 7.86 GB less (80.12%) |
| PostHog | Commit Build | 24m 10s | 13m 38s | 44% faster | n/a |
| Storybook | Commit Build | 2m 48s | 3m 27s | 23% slower | 1.04 GB less (53.56%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 0m 39s | 0m 41s | near tie | 886.49 MB less (40.07%) |
| gRPC | Commit Build | 1m 15s | 0m 57s | 24% faster | n/a |
| Zed | Commit Build | 33m 5s | 34m 17s | 4% slower | 1.46 GB more (13.03%) |
| n8n | Commit Build | 3m 30s | 3m 28s | near tie | 369.03 MB less (10.9%) |
| n8n Docker | Commit Build | 4m 46s | 2m 59s | 37% faster | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 42s | 22% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 57s | 1m 8s | 42% faster | n/a |
