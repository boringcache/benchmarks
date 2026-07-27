# Latest Benchmark Report

Generated: 2026-07-27 21:00 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 24s | 1m 33s | 11% slower | 510.87 MB more (168.37%) |
| Storybook | Cold Build | 3m 35s | 3m 40s | near tie | n/a |
| OpenTelemetry Java | Cold Build | 11m 24s | 11m 1s | 3% faster | n/a |
| Spring AI | Warm Build | 0m 38s | 0m 30s | 21% faster | n/a |
| gRPC | Cold Build | 26m 6s | 0m 44s | 97% faster | n/a |
| Zed | Cold Build | 55m 34s | 47m 50s | 14% faster | n/a |
| n8n | Cold Build | 3m 38s | 1m 30s | 59% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 5s | 2m 56s | 5% faster | 5.97 GB less (94.62%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 12m 51s | 3m 32s | 73% faster | 7.53 GB less (72.34%) |
| Mastodon | Commit Build | 2m 27s | 1m 32s | 37% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 7s | near tie | n/a |
| Discourse | Commit Build | 3m 55s | 2m 46s | 29% faster | 8.90 GB less (89.6%) |
| Discourse Base Deps | Commit Build | 0m 10s | 0m 7s | near tie | 9.14 GB less (92.86%) |
| Discourse Web-Only Image | Commit Build | 0m 9s | 0m 9s | near tie | 8.52 GB less (86.58%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 9s | near tie | 8.42 GB less (85.57%) |
| Discourse Test Image | Commit Build | 0m 12s | 0m 8s | near tie | 7.89 GB less (80.18%) |
| PostHog | Commit Build | 23m 17s | 13m 41s | 41% faster | n/a |
| Storybook | Commit Build | 1m 33s | 1m 26s | 8% faster | 1.16 GB less (57.65%) |
| OpenTelemetry Java | Commit Build | 5m 52s | 5m 33s | 5% faster | 2.28 GB less (77.95%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 1m 57s | 0m 45s | 62% faster | n/a |
| Zed | Commit Build | 20m 1s | 20m 12s | near tie | 7.66 GB more (68.63%) |
| n8n | Commit Build | 3m 15s | 3m 3s | 6% faster | 3.37 GB less (77.87%) |
| n8n Docker | Commit Build | 5m 28s | 3m 24s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 48s | 11% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 16s | 1m 18s | 43% faster | n/a |
