# Latest Benchmark Report

Generated: 2026-07-24 13:10 UTC

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
| Mastodon | Commit Build | 2m 27s | 1m 52s | 24% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 15s | 0m 8s | 47% faster | n/a |
| Discourse | Commit Build | 4m 5s | 2m 34s | 37% faster | 8.96 GB less (89.67%) |
| Discourse Base Deps | Commit Build | 0m 10s | 0m 6s | near tie | 9.64 GB less (93.21%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 9s | 40% faster | 9.03 GB less (87.23%) |
| Discourse Release Image | Commit Build | 0m 32s | 0m 11s | 66% faster | 8.58 GB less (85.79%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 9s | 40% faster | 8.40 GB less (81.15%) |
| PostHog | Commit Build | 21m 25s | 13m 52s | 35% faster | n/a |
| Storybook | Commit Build | 2m 59s | 3m 23s | 13% slower | 990.52 MB less (51.74%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 4m 18s | 4m 19s | near tie | 205.07 MB more (21.74%) |
| gRPC | Commit Build | 23m 4s | 13m 45s | 40% faster | n/a |
| Zed | Commit Build | 26m 21s | 25m 59s | near tie | 2.12 GB less (18.94%) |
| n8n | Commit Build | 3m 21s | 3m 7s | 7% faster | 64.64 MB less (2.1%) |
| n8n Docker | Commit Build | 5m 23s | 3m 53s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 15s | 0m 39s | 48% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 20s | 1m 6s | 53% faster | n/a |
