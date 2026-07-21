# Latest Benchmark Report

Generated: 2026-07-21 20:59 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 25s | near tie | 36.20 MB less (11.94%) |
| Storybook | Cold Build | 3m 41s | 3m 48s | 3% slower | 41.13 MB more (4.69%) |
| OpenTelemetry Java | Cold Build | 11m 14s | 10m 57s | near tie | 49.71 MB less (6.08%) |
| Spring AI | Cold Build | 4m 32s | 4m 56s | 9% slower | 176.77 MB less (18.73%) |
| gRPC | Cold Build | 38m 14s | 23m 20s | 39% faster | n/a |
| Zed | Warm Build | 19m 25s | 16m 50s | 13% faster | 2.11 GB less (78.0%) |
| n8n | Cold Build | 3m 44s | 3m 54s | 4% slower | 7.75 MB more (1.0%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 11s | 0m 8s | near tie | 119.70 MB less (25.62%) |
| Hugo Go | Commit Build | 1m 29s | 1m 25s | 4% faster | 36.25 MB less (11.95%) |
| Immich | Commit Build | 6m 13s | 5m 31s | 11% faster | 7.06 GB less (71.01%) |
| Mastodon | Commit Build | 2m 9s | 2m 47s | 29% slower | 7.85 GB less (88.37%) |
| Mastodon Streaming | Commit Build | 0m 9s | 0m 9s | near tie | 8.78 GB less (98.86%) |
| Discourse | Commit Build | 4m 34s | 3m 8s | 31% faster | 8.92 GB less (89.63%) |
| Discourse Base Deps | Commit Build | 0m 16s | 0m 8s | 50% faster | 9.22 GB less (92.92%) |
| Discourse Web-Only Image | Commit Build | 0m 13s | 0m 15s | near tie | 8.52 GB less (85.86%) |
| Discourse Release Image | Commit Build | 0m 18s | 0m 10s | 44% faster | 8.42 GB less (84.85%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 11s | near tie | 7.97 GB less (80.35%) |
| PostHog | Commit Build | 21m 0s | 17m 57s | 15% faster | 4.07 GB less (36.31%) |
| Storybook | Commit Build | 3m 51s | 3m 23s | 12% faster | 5.60 GB less (86.21%) |
| OpenTelemetry Java | Commit Build | 1m 19s | 11m 26s | 768% slower | 3.08 GB less (80.41%) |
| Spring AI | Commit Build | 0m 59s | 0m 37s | 37% faster | 3.26 GB less (70.17%) |
| gRPC | Commit Build | 2m 44s | 0m 39s | 76% faster | n/a |
| Zed | Commit Build | 21m 13s | 19m 46s | 7% faster | 10.59 GB less (92.16%) |
| n8n | Commit Build | 1m 3s | 1m 14s | 17% slower | 2.45 GB less (75.66%) |
| n8n Docker | Commit Build | 5m 8s | 4m 51s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 1s | 0m 55s | 10% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 14s | 1m 34s | 30% faster | n/a |
