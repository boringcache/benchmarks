# Latest Benchmark Report

Generated: 2026-05-22 17:28 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 35s | 3m 23s | 6% faster | 6.78 GB less (95.33%) |
| Hugo Go | Cold Build | 1m 19s | 1m 23s | 5% slower | 40.34 MB less (13.72%) |
| Immich | Cold Build | 5m 31s | 4m 39s | 16% faster | 7.77 GB less (77.84%) |
| Mastodon | Cold Build | 9m 57s | 9m 9s | 8% faster | 9.78 GB less (90.56%) |
| Mastodon Streaming | Cold Build | 0m 25s | 0m 37s | 48% slower | 10.29 GB less (99.03%) |
| Discourse | Cold Build | 5m 24s | 5m 7s | 5% faster | 9.90 GB less (90.5%) |
| Discourse Base Deps | Cold Build | 4m 50s | 4m 40s | 3% faster | 9.17 GB less (93.25%) |
| Discourse Web-Only Image | Cold Build | 7m 17s | 7m 8s | near tie | 8.57 GB less (87.11%) |
| Discourse Release Image | Warm Build | 0m 12s | 0m 8s | near tie | 8.48 GB less (86.27%) |
| Discourse Test Image | Cold Build | 9m 1s | 7m 9s | 21% faster | 7.90 GB less (80.39%) |
| PostHog | Cold Build | 24m 51s | 21m 18s | 14% faster | 5.05 GB less (43.92%) |
| Storybook | Warm Build | 3m 28s | 0m 46s | 78% faster | 44.30 MB more (6.06%) |
| OpenTelemetry Java | Cold Build | 11m 21s | 10m 59s | 3% faster | 52.70 MB less (5.89%) |
| Spring AI | Cold Build | 3m 51s | 3m 58s | 3% slower | 177.45 MB less (18.84%) |
| gRPC | Cold Build | 28m 23s | 24m 34s | 13% faster | n/a |
| Zed | Cold Build | 50m 4s | 50m 39s | near tie | 2.05 GB less (73.62%) |
| n8n | Cold Build | 5m 7s | 4m 55s | 4% faster | 15.86 MB more (2.13%) |
| n8n Docker | Cold Build | 4m 10s | 3m 50s | 8% faster | n/a |
| n8n Runners | Cold Build | 1m 17s | 1m 12s | 6% faster | n/a |
| n8n Runners Distroless | Cold Build | 3m 26s | 1m 45s | 49% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 33s | 2m 50s | 11% slower | 6.75 GB less (95.31%) |
| Hugo Go | Commit Build | 0m 33s | 0m 26s | 21% faster | 1.12 GB less (81.24%) |
| Immich | Commit Build | 3m 17s | 3m 5s | 6% faster | 7.23 GB less (77.7%) |
| Mastodon | Commit Build | 2m 54s | 1m 59s | 32% faster | 9.36 GB less (90.18%) |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 9s | near tie | 10.28 GB less (99.03%) |
| Discourse | Commit Build | 3m 15s | 3m 33s | 9% slower | 8.88 GB less (89.65%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 9s | near tie | 9.25 GB less (93.31%) |
| Discourse Web-Only Image | Commit Build | 0m 14s | 0m 16s | near tie | 8.64 GB less (87.22%) |
| Discourse Release Image | Commit Build | 0m 21s | 0m 9s | 57% faster | 8.56 GB less (86.38%) |
| Discourse Test Image | Commit Build | 0m 11s | 0m 9s | near tie | 7.98 GB less (80.55%) |
| PostHog | Commit Build | 16m 55s | 12m 30s | 26% faster | 4.91 GB less (44.64%) |
| Storybook | Commit Build | 3m 27s | 3m 32s | near tie | 1.69 GB less (68.51%) |
| OpenTelemetry Java | Commit Build | 5m 21s | 4m 44s | 12% faster | 3.12 GB less (77.86%) |
| Spring AI | Commit Build | 0m 49s | 0m 47s | near tie | 2.70 GB less (75.53%) |
| gRPC | Commit Build | 1m 20s | 1m 37s | 21% slower | n/a |
| Zed | Commit Build | 35m 5s | 34m 34s | near tie | 10.73 GB less (93.58%) |
| n8n | Commit Build | 2m 45s | 2m 30s | 9% faster | 5.99 GB less (88.77%) |
| n8n Docker | Commit Build | 4m 11s | 3m 44s | 11% faster | n/a |
| n8n Runners | Commit Build | 0m 57s | 0m 54s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 1m 33s | 1m 29s | 4% faster | n/a |
