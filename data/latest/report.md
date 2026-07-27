# Latest Benchmark Report

Generated: 2026-07-27 17:13 UTC

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
| Immich | Commit Build | 0m 11s | 0m 16s | near tie | 7.23 GB less (71.51%) |
| Mastodon | Commit Build | 2m 27s | 1m 32s | 37% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 7s | near tie | n/a |
| Discourse | Commit Build | 3m 16s | 2m 45s | 16% faster | 8.91 GB less (89.61%) |
| Discourse Base Deps | Commit Build | 0m 18s | 0m 18s | near tie | 9.24 GB less (92.94%) |
| Discourse Web-Only Image | Commit Build | 0m 16s | 0m 11s | near tie | 8.62 GB less (86.71%) |
| Discourse Release Image | Commit Build | 0m 21s | 0m 13s | 38% faster | 8.52 GB less (85.71%) |
| Discourse Test Image | Commit Build | 0m 11s | 0m 9s | near tie | 7.99 GB less (80.38%) |
| PostHog | Commit Build | 25m 41s | 16m 22s | 36% faster | n/a |
| Storybook | Commit Build | 1m 33s | 1m 26s | 8% faster | 1.16 GB less (57.65%) |
| OpenTelemetry Java | Commit Build | 1m 12s | 2m 6s | 75% slower | 2.47 GB less (79.16%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 16m 56s | 11m 48s | 30% faster | n/a |
| Zed | Commit Build | 20m 1s | 20m 12s | near tie | 7.66 GB more (68.63%) |
| n8n | Commit Build | 3m 20s | 4m 4s | 22% slower | 3.34 GB less (78.17%) |
| n8n Docker | Commit Build | 5m 53s | 3m 36s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 55s | 0m 50s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 2m 15s | 1m 5s | 52% faster | n/a |
