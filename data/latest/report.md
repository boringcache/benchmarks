# Latest Benchmark Report

Generated: 2026-06-05 09:52 UTC

Coverage: 20 benchmarks; fresh 5/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 20s | 3m 37s | 9% slower | 44.78 MB more (6.13%) |
| OpenTelemetry Java | Warm Build | 1m 0s | 0m 54s | 10% faster | 52.36 MB less (5.85%) |
| Spring AI | Warm Build | 0m 35s | 0m 28s | 20% faster | 175.44 MB less (18.42%) |
| gRPC | Cold Build | 32m 26s | 22m 58s | 29% faster | n/a |
| Zed | Cold Build | 51m 38s | 51m 26s | near tie | 2.09 GB less (75.51%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 8s | 2m 51s | 9% faster | 2.99 GB less (89.9%) |
| Hugo Go | Commit Build | 0m 46s | 0m 48s | near tie | 1021.01 MB less (78.21%) |
| Immich | Commit Build | 3m 28s | 2m 49s | 19% faster | 7.30 GB less (77.72%) |
| Mastodon | Commit Build | 3m 22s | 2m 54s | 14% faster | 8.97 GB less (89.93%) |
| Mastodon Streaming | Commit Build | 0m 28s | 0m 18s | 36% faster | 9.87 GB less (98.99%) |
| Discourse | Commit Build | 3m 19s | 2m 59s | 10% faster | 8.92 GB less (89.74%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 13s | near tie | 9.30 GB less (93.51%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 8s | near tie | 8.71 GB less (87.56%) |
| Discourse Release Image | Commit Build | 0m 7s | 0m 10s | near tie | 8.61 GB less (86.56%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 7s | near tie | 8.03 GB less (80.75%) |
| PostHog | Commit Build | 18m 23s | 12m 4s | 34% faster | 5.06 GB less (45.65%) |
| Storybook | Commit Build | 3m 41s | 3m 20s | 10% faster | 2.40 GB less (74.86%) |
| OpenTelemetry Java | Commit Build | 7m 5s | 7m 18s | 3% slower | 2.36 GB less (72.71%) |
| Spring AI | Commit Build | 0m 49s | 0m 34s | 31% faster | 2.77 GB less (74.67%) |
| gRPC | Commit Build | 19m 53s | 13m 11s | 34% faster | n/a |
| Zed | Commit Build | 51m 56s | 32m 19s | 38% faster | 1.94 GB less (70.07%) |
| n8n | Commit Build | 6m 19s | 5m 22s | 15% faster | 5.61 GB less (87.77%) |
| n8n Docker | Commit Build | 5m 41s | 4m 31s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 17s | 0m 45s | 42% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 4s | 1m 30s | 27% faster | n/a |
