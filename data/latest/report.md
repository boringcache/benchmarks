# Latest Benchmark Report

Generated: 2026-07-22 01:04 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 27s | 1m 25s | near tie | 36.23 MB less (11.95%) |
| Storybook | Cold Build | 3m 35s | 3m 9s | 12% faster | 41.05 MB more (4.68%) |
| OpenTelemetry Java | Cold Build | 18m 14s | 10m 55s | 40% faster | 48.45 MB less (6.08%) |
| Spring AI | Cold Build | 4m 34s | 4m 28s | near tie | 176.77 MB less (18.73%) |
| gRPC | Cold Build | 37m 41s | 18m 14s | 52% faster | n/a |
| Zed | Cold Build | 55m 30s | 54m 13s | near tie | 2.12 GB less (78.07%) |
| n8n | Cold Build | 3m 32s | 3m 37s | near tie | 7.65 MB more (0.99%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 11s | 0m 8s | near tie | 119.70 MB less (25.62%) |
| Hugo Go | Commit Build | 0m 16s | 0m 21s | near tie | 339.44 MB less (55.97%) |
| Immich | Commit Build | 0m 17s | 0m 8s | 53% faster | 7.06 GB less (71.02%) |
| Mastodon | Commit Build | 2m 9s | 2m 47s | 29% slower | 7.85 GB less (88.37%) |
| Mastodon Streaming | Commit Build | 0m 9s | 0m 9s | near tie | 8.78 GB less (98.86%) |
| Discourse | Commit Build | 3m 13s | 2m 46s | 14% faster | 8.75 GB less (89.45%) |
| Discourse Base Deps | Commit Build | 0m 15s | 0m 20s | near tie | 9.08 GB less (92.82%) |
| Discourse Web-Only Image | Commit Build | 0m 10s | 0m 8s | near tie | 8.38 GB less (85.67%) |
| Discourse Release Image | Commit Build | 0m 15s | 0m 9s | 40% faster | 8.28 GB less (84.65%) |
| Discourse Test Image | Commit Build | 0m 10s | 0m 9s | near tie | 7.84 GB less (80.08%) |
| PostHog | Commit Build | 23m 34s | 19m 10s | 19% faster | 2.73 GB less (27.65%) |
| Storybook | Commit Build | 1m 24s | 0m 48s | 43% faster | 5.64 GB less (86.28%) |
| OpenTelemetry Java | Commit Build | 1m 14s | 1m 3s | 15% faster | 2.94 GB less (80.1%) |
| Spring AI | Commit Build | 0m 50s | 0m 40s | 20% faster | 3.26 GB less (70.17%) |
| gRPC | Commit Build | 1m 47s | 0m 46s | 57% faster | n/a |
| Zed | Commit Build | 17m 44s | 21m 9s | 19% slower | 10.58 GB less (92.15%) |
| n8n | Commit Build | 1m 4s | 2m 2s | 91% slower | 2.53 GB less (76.25%) |
| n8n Docker | Commit Build | 3m 56s | 4m 29s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 54s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 1m 53s | 1m 39s | 12% faster | n/a |
