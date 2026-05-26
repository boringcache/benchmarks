# Latest Benchmark Report

Generated: 2026-05-26 21:28 UTC

Coverage: 20 benchmarks; fresh 19/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 22s | 3m 30s | 4% slower | 2.04 GB less (86.0%) |
| Hugo Go | Cold Build | 1m 20s | 1m 23s | 4% slower | 42.35 MB less (14.3%) |
| Immich | Warm Build | 0m 10s | 0m 7s | near tie | 8.34 GB less (80.1%) |
| Mastodon | Cold Build | 9m 35s | 9m 5s | 5% faster | 8.98 GB less (89.8%) |
| Mastodon Streaming | Cold Build | 0m 21s | 0m 42s | 100% slower | 9.89 GB less (98.99%) |
| Discourse | Cold Build | 5m 50s | 5m 4s | 13% faster | 8.97 GB less (89.75%) |
| Discourse Base Deps | Warm Build | 0m 11s | 0m 8s | near tie | 9.31 GB less (93.35%) |
| Discourse Web-Only Image | Warm Build | 0m 11s | 0m 10s | near tie | 8.71 GB less (87.3%) |
| Discourse Release Image | Cold Build | 8m 46s | 7m 29s | 15% faster | 8.63 GB less (86.46%) |
| Discourse Test Image | Cold Build | 8m 57s | 7m 45s | 13% faster | 8.05 GB less (80.68%) |
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
| Hugo | Commit Build | 3m 24s | 3m 1s | 11% faster | 1.97 GB less (85.45%) |
| Hugo Go | Commit Build | 0m 33s | 0m 27s | 18% faster | 1.52 GB less (84.54%) |
| Immich | Commit Build | 5m 3s | 4m 29s | 11% faster | 7.78 GB less (78.93%) |
| Mastodon | Commit Build | 2m 9s | 1m 58s | 9% faster | 8.95 GB less (89.77%) |
| Mastodon Streaming | Commit Build | 0m 10s | 0m 7s | near tie | 9.87 GB less (98.99%) |
| Discourse | Commit Build | 3m 22s | 3m 21s | near tie | 8.86 GB less (89.62%) |
| Discourse Base Deps | Commit Build | 0m 7s | 0m 7s | near tie | 9.22 GB less (93.29%) |
| Discourse Web-Only Image | Commit Build | 0m 9s | 0m 8s | near tie | 8.61 GB less (87.18%) |
| Discourse Release Image | Commit Build | 0m 12s | 0m 7s | near tie | 8.53 GB less (86.33%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 20s | near tie | 7.95 GB less (80.49%) |
| PostHog | Commit Build | 14m 43s | 12m 43s | 14% faster | 3.86 GB less (38.56%) |
| Storybook | Commit Build | 3m 16s | 3m 42s | 13% slower | 1.74 GB less (68.89%) |
| OpenTelemetry Java | Commit Build | 5m 21s | 4m 44s | 12% faster | 3.12 GB less (77.86%) |
| Spring AI | Commit Build | 3m 11s | 3m 10s | near tie | 2.70 GB less (75.53%) |
| gRPC | Commit Build | 0m 54s | 0m 45s | 17% faster | n/a |
| Zed | Commit Build | 36m 37s | 37m 29s | near tie | 10.70 GB less (93.52%) |
| n8n | Commit Build | 3m 55s | 3m 46s | 4% faster | 7.15 GB less (90.33%) |
| n8n Docker | Commit Build | 4m 25s | 3m 27s | 22% faster | n/a |
| n8n Runners | Commit Build | 0m 52s | 0m 49s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 1m 33s | 1m 25s | 9% faster | n/a |
