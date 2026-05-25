# Latest Benchmark Report

Generated: 2026-05-25 17:27 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 22s | 3m 30s | 4% slower | 2.04 GB less (86.0%) |
| Hugo Go | Cold Build | 1m 20s | 1m 23s | 4% slower | 42.35 MB less (14.3%) |
| Immich | Cold Build | 5m 31s | 4m 39s | 16% faster | 7.77 GB less (77.84%) |
| Mastodon | Cold Build | 9m 57s | 9m 9s | 8% faster | 9.78 GB less (90.56%) |
| Mastodon Streaming | Cold Build | 0m 25s | 0m 37s | 48% slower | 10.29 GB less (99.03%) |
| Discourse | Cold Build | 5m 50s | 5m 4s | 13% faster | 8.97 GB less (89.75%) |
| Discourse Base Deps | Warm Build | 0m 11s | 0m 8s | near tie | 9.31 GB less (93.35%) |
| Discourse Web-Only Image | Warm Build | 0m 11s | 0m 10s | near tie | 8.71 GB less (87.3%) |
| Discourse Release Image | Cold Build | 8m 46s | 7m 29s | 15% faster | 8.63 GB less (86.46%) |
| Discourse Test Image | Cold Build | 8m 57s | 7m 45s | 13% faster | 8.05 GB less (80.68%) |
| PostHog | Cold Build | 24m 51s | 21m 18s | 14% faster | 5.05 GB less (43.92%) |
| Storybook | Warm Build | 3m 28s | 0m 46s | 78% faster | 44.30 MB more (6.06%) |
| OpenTelemetry Java | Cold Build | 11m 21s | 10m 59s | 3% faster | 52.70 MB less (5.89%) |
| Spring AI | Cold Build | 3m 51s | 3m 58s | 3% slower | 177.45 MB less (18.84%) |
| gRPC | Cold Build | 28m 23s | 24m 34s | 13% faster | n/a |
| Zed | Cold Build | 50m 4s | 50m 39s | near tie | 2.05 GB less (73.62%) |
| n8n | Cold Build | 5m 21s | 5m 8s | 4% faster | 14.91 MB more (2.0%) |
| n8n Docker | Warm Build | 2m 6s | 2m 2s | 3% faster | n/a |
| n8n Runners | Cold Build | 1m 2s | 1m 3s | near tie | n/a |
| n8n Runners Distroless | Warm Build | 1m 2s | 0m 57s | 8% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 2.02 GB less (85.87%) |
| Hugo Go | Commit Build | 0m 34s | 0m 25s | 26% faster | 1.27 GB less (82.49%) |
| Immich | Commit Build | 2m 59s | 2m 51s | 4% faster | 7.55 GB less (78.46%) |
| Mastodon | Commit Build | 2m 8s | 2m 30s | 17% slower | 8.98 GB less (89.8%) |
| Mastodon Streaming | Commit Build | 0m 13s | 0m 8s | near tie | 9.89 GB less (98.99%) |
| Discourse | Commit Build | 3m 21s | 3m 20s | near tie | 9.13 GB less (89.91%) |
| Discourse Base Deps | Commit Build | 0m 11s | 0m 9s | near tie | 10.04 GB less (93.8%) |
| Discourse Web-Only Image | Commit Build | 0m 16s | 0m 8s | 50% faster | 9.44 GB less (88.16%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 8s | near tie | 9.35 GB less (87.38%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 8s | near tie | 8.78 GB less (81.99%) |
| PostHog | Commit Build | 13m 53s | 11m 52s | 15% faster | 3.35 GB less (34.3%) |
| Storybook | Commit Build | 3m 27s | 3m 32s | near tie | 1.69 GB less (68.51%) |
| OpenTelemetry Java | Commit Build | 5m 21s | 4m 44s | 12% faster | 3.12 GB less (77.86%) |
| Spring AI | Commit Build | 1m 23s | 1m 23s | near tie | 2.70 GB less (75.53%) |
| gRPC | Commit Build | 8m 25s | 6m 10s | 27% faster | n/a |
| Zed | Commit Build | 37m 49s | 36m 27s | 4% faster | 10.71 GB less (93.52%) |
| n8n | Commit Build | 3m 23s | 2m 7s | 37% faster | 6.63 GB less (89.68%) |
| n8n Docker | Commit Build | 3m 53s | 2m 49s | 27% faster | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 49s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 1m 35s | 1m 31s | 4% faster | n/a |
