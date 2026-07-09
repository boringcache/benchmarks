# Latest Benchmark Report

Generated: 2026-07-09 01:15 UTC

Coverage: 20 benchmarks; fresh 5/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Warm Build | 0m 53s | 0m 46s | 13% faster | 47.04 MB more (6.0%) |
| OpenTelemetry Java | Warm Build | 1m 1s | 0m 59s | 3% faster | 49.63 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 23s | 28% faster | 177.03 MB less (17.99%) |
| gRPC | Cold Build | 32m 56s | 23m 35s | 28% faster | n/a |
| n8n | Cold Build | 5m 41s | 5m 47s | near tie | 9.61 MB more (1.32%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 49s | 2m 44s | near tie | 1.60 GB less (82.52%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 8m 38s | 5m 11s | 40% faster | 7.10 GB less (72.75%) |
| Mastodon | Commit Build | 0m 16s | 0m 16s | near tie | 9.25 GB less (90.02%) |
| Mastodon Streaming | Commit Build | 0m 12s | 0m 9s | near tie | 9.89 GB less (98.99%) |
| Discourse | Commit Build | 3m 9s | 4m 0s | 27% slower | 8.73 GB less (89.46%) |
| Discourse Base Deps | Commit Build | 0m 15s | 0m 9s | 40% faster | 9.49 GB less (93.11%) |
| Discourse Web-Only Image | Commit Build | 0m 13s | 0m 12s | near tie | 8.88 GB less (87.1%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 10s | 38% faster | 8.78 GB less (86.13%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 13s | near tie | 8.25 GB less (80.94%) |
| PostHog | Commit Build | 21m 52s | 12m 11s | 44% faster | 7.75 GB less (53.32%) |
| Storybook | Commit Build | 4m 20s | 3m 47s | 13% faster | 4.90 GB less (85.54%) |
| OpenTelemetry Java | Commit Build | 5m 54s | 5m 30s | 7% faster | 3.13 GB less (80.52%) |
| Spring AI | Commit Build | 0m 51s | 0m 34s | 33% faster | 3.20 GB less (70.43%) |
| gRPC | Commit Build | 7m 17s | 4m 13s | 42% faster | n/a |
| Zed | Commit Build | 40m 34s | 38m 44s | 5% faster | 10.49 GB less (92.25%) |
| n8n | Commit Build | 1m 44s | 1m 4s | 38% faster | 11.16 GB less (93.79%) |
| n8n Docker | Commit Build | 5m 22s | 4m 44s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 50s | 0m 52s | 53% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 59s | 1m 20s | 55% faster | n/a |
