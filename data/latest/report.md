# Latest Benchmark Report

Generated: 2026-07-24 01:06 UTC

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
| Immich | Commit Build | 3m 54s | 3m 11s | 18% faster | 6.59 GB less (69.59%) |
| Mastodon | Commit Build | 0m 22s | 0m 15s | 32% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 13s | 0m 12s | near tie | n/a |
| Discourse | Commit Build | 3m 14s | 2m 34s | 21% faster | 8.92 GB less (89.62%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 6s | near tie | 9.25 GB less (92.94%) |
| Discourse Web-Only Image | Commit Build | 0m 16s | 0m 7s | 56% faster | 8.63 GB less (86.73%) |
| Discourse Release Image | Commit Build | 0m 17s | 0m 8s | 53% faster | 8.53 GB less (85.73%) |
| Discourse Test Image | Commit Build | 0m 13s | 0m 7s | 46% faster | 8.00 GB less (80.4%) |
| PostHog | Commit Build | 27m 1s | 13m 40s | 49% faster | n/a |
| Storybook | Commit Build | 0m 51s | 1m 11s | 39% slower | 908.18 MB less (49.76%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 4m 18s | 4m 19s | near tie | 205.07 MB more (21.74%) |
| gRPC | Commit Build | 23m 4s | 13m 45s | 40% faster | n/a |
| Zed | Commit Build | 38m 29s | 38m 56s | near tie | 3.71 GB less (39.2%) |
| n8n | Commit Build | 1m 21s | 1m 32s | 14% slower | 469.34 MB more (17.88%) |
| n8n Docker | Commit Build | 5m 43s | 6m 10s | 8% slower | n/a |
| n8n Runners | Commit Build | 1m 17s | 0m 45s | 42% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 52s | 1m 6s | 41% faster | n/a |
