# Latest Benchmark Report

Generated: 2026-07-24 09:22 UTC

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
| Immich | Commit Build | 4m 1s | 2m 26s | 39% faster | 7.00 GB less (70.84%) |
| Mastodon | Commit Build | 3m 24s | 2m 18s | 32% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 13s | 0m 10s | near tie | n/a |
| Discourse | Commit Build | 4m 4s | 2m 35s | 36% faster | 8.96 GB less (89.67%) |
| Discourse Base Deps | Commit Build | 0m 16s | 0m 8s | 50% faster | 9.30 GB less (92.98%) |
| Discourse Web-Only Image | Commit Build | 0m 7s | 0m 9s | near tie | 8.97 GB less (87.16%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 16s | 100% slower | 8.87 GB less (86.2%) |
| Discourse Test Image | Commit Build | 0m 12s | 0m 6s | 50% faster | 8.05 GB less (80.49%) |
| PostHog | Commit Build | 26m 2s | 13m 44s | 47% faster | n/a |
| Storybook | Commit Build | 2m 53s | 3m 22s | 17% slower | 924.78 MB less (50.2%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 4m 18s | 4m 19s | near tie | 205.07 MB more (21.74%) |
| gRPC | Commit Build | 23m 4s | 13m 45s | 40% faster | n/a |
| Zed | Commit Build | 45m 57s | 44m 39s | near tie | 3.54 GB less (31.82%) |
| n8n | Commit Build | 3m 34s | 3m 18s | 7% faster | 359.12 MB more (13.17%) |
| n8n Docker | Commit Build | 5m 19s | 3m 33s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 53s | 0m 42s | 21% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 45s | 1m 10s | 33% faster | n/a |
