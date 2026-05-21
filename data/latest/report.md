# Latest Benchmark Report

Generated: 2026-05-21 17:34 UTC

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
| gRPC | Cold Build | 28m 10s | 24m 38s | 13% faster | n/a |
| Zed | Cold Build | 49m 41s | 42m 50s | 14% faster | n/a |
| n8n | Cold Build | 5m 7s | 4m 55s | 4% faster | 15.86 MB more (2.13%) |
| n8n Docker | Cold Build | 4m 10s | 3m 50s | 8% faster | n/a |
| n8n Runners | Cold Build | 1m 17s | 1m 12s | 6% faster | n/a |
| n8n Runners Distroless | Cold Build | 3m 26s | 1m 45s | 49% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 48s | 2m 45s | near tie | 7.21 GB less (95.59%) |
| Hugo Go | Commit Build | 0m 25s | 0m 25s | near tie | 1.06 GB less (80.4%) |
| Immich | Commit Build | 0m 24s | 0m 14s | 42% faster | 7.22 GB less (77.69%) |
| Mastodon | Commit Build | 3m 57s | 1m 47s | 55% faster | 8.94 GB less (89.77%) |
| Mastodon Streaming | Commit Build | 0m 15s | 0m 6s | 60% faster | 9.86 GB less (98.99%) |
| Discourse | Commit Build | 4m 7s | 2m 57s | 28% faster | 8.97 GB less (89.75%) |
| Discourse Base Deps | Commit Build | 0m 10s | 0m 8s | near tie | 10.13 GB less (93.85%) |
| Discourse Web-Only Image | Commit Build | 0m 11s | 0m 7s | near tie | 8.45 GB less (86.96%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 12s | near tie | 8.37 GB less (86.1%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 7s | 50% faster | 7.79 GB less (80.16%) |
| PostHog | Commit Build | 15m 4s | 12m 9s | 19% faster | 3.49 GB less (36.15%) |
| Storybook | Commit Build | 3m 28s | 3m 27s | near tie | 1.45 GB less (65.24%) |
| OpenTelemetry Java | Commit Build | 8m 14s | 1m 13s | 85% faster | 3.01 GB less (77.2%) |
| Spring AI | Commit Build | 2m 17s | 2m 1s | 12% faster | 2.62 GB less (76.63%) |
| gRPC | Commit Build | 8m 18s | 5m 51s | 30% faster | n/a |
| Zed | Commit Build | 40m 4s | 38m 33s | 4% faster | 10.72 GB less (93.57%) |
| n8n | Commit Build | 4m 4s | 3m 58s | near tie | 5.37 GB less (87.64%) |
| n8n Docker | Commit Build | 4m 37s | 3m 47s | 18% faster | n/a |
| n8n Runners | Commit Build | 1m 2s | 0m 51s | 18% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 52s | 1m 29s | 48% faster | n/a |
