# Latest Benchmark Report

Generated: 2026-07-24 17:08 UTC

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
| Immich | Commit Build | 4m 22s | 3m 25s | 22% faster | 6.24 GB less (68.41%) |
| Mastodon | Commit Build | 3m 1s | 1m 35s | 48% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 6s | 0m 16s | 167% slower | n/a |
| Discourse | Commit Build | 3m 38s | 2m 46s | 24% faster | 8.49 GB less (89.16%) |
| Discourse Base Deps | Commit Build | 0m 10s | 0m 12s | near tie | 9.50 GB less (93.12%) |
| Discourse Web-Only Image | Commit Build | 0m 14s | 0m 7s | 50% faster | 8.20 GB less (86.13%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 10s | near tie | 8.79 GB less (86.09%) |
| Discourse Test Image | Commit Build | 0m 18s | 0m 15s | near tie | 7.57 GB less (79.52%) |
| PostHog | Commit Build | 30m 37s | 13m 26s | 56% faster | n/a |
| Storybook | Commit Build | 2m 48s | 3m 27s | 23% slower | 1.04 GB less (53.56%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 4m 18s | 4m 19s | near tie | 205.07 MB more (21.74%) |
| gRPC | Commit Build | 2m 21s | 0m 40s | 72% faster | n/a |
| Zed | Commit Build | 22m 46s | 24m 42s | 8% slower | 1.30 GB less (11.68%) |
| n8n | Commit Build | 1m 44s | 1m 33s | 11% faster | 322.39 MB less (9.67%) |
| n8n Docker | Commit Build | 5m 11s | 3m 37s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 7s | 0m 44s | 34% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 45s | 1m 3s | 40% faster | n/a |
