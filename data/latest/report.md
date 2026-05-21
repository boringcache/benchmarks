# Latest Benchmark Report

Generated: 2026-05-21 21:12 UTC

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
| Hugo | Commit Build | 3m 0s | 2m 57s | near tie | 7.36 GB less (95.68%) |
| Hugo Go | Commit Build | 0m 30s | 0m 28s | near tie | 1.10 GB less (81.06%) |
| Immich | Commit Build | 0m 14s | 0m 7s | 50% faster | 7.23 GB less (77.7%) |
| Mastodon | Commit Build | 3m 0s | 1m 57s | 35% faster | 8.95 GB less (89.77%) |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 8s | near tie | 9.87 GB less (98.99%) |
| Discourse | Commit Build | 4m 0s | 2m 43s | 32% faster | 9.48 GB less (90.25%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 7s | near tie | 9.84 GB less (93.69%) |
| Discourse Web-Only Image | Commit Build | 0m 9s | 0m 7s | near tie | 9.24 GB less (87.94%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 15s | near tie | 9.16 GB less (87.15%) |
| Discourse Test Image | Commit Build | 0m 10s | 0m 9s | near tie | 8.58 GB less (81.65%) |
| PostHog | Commit Build | 23m 24s | 14m 10s | 39% faster | 3.98 GB less (38.12%) |
| Storybook | Commit Build | 3m 28s | 3m 27s | near tie | 1.45 GB less (65.24%) |
| OpenTelemetry Java | Commit Build | 8m 14s | 1m 13s | 85% faster | 3.01 GB less (77.2%) |
| Spring AI | Commit Build | 0m 52s | 0m 36s | 31% faster | 2.62 GB less (76.62%) |
| gRPC | Commit Build | 4m 27s | 3m 45s | 16% faster | n/a |
| Zed | Commit Build | 22m 5s | 20m 50s | 6% faster | 10.72 GB less (93.57%) |
| n8n | Commit Build | 2m 32s | 2m 14s | 12% faster | 5.41 GB less (87.73%) |
| n8n Docker | Commit Build | 4m 21s | 3m 46s | 13% faster | n/a |
| n8n Runners | Commit Build | 1m 23s | 0m 52s | 37% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 12s | 1m 27s | 34% faster | n/a |
