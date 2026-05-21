# Latest Benchmark Report

Generated: 2026-05-21 13:45 UTC

Coverage: 12 benchmarks; fresh 12/12, rolling 12/12.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 35s | 3m 23s | 6% faster | 6.78 GB less (95.33%) |
| Hugo Go | Cold Build | 1m 19s | 1m 23s | 5% slower | 40.34 MB less (13.72%) |
| Immich | Cold Build | 5m 31s | 4m 39s | 16% faster | 7.77 GB less (77.84%) |
| Mastodon | Cold Build | 9m 57s | 9m 9s | 8% faster | 9.78 GB less (90.56%) |
| Discourse | Cold Build | 5m 24s | 5m 7s | 5% faster | 9.90 GB less (90.5%) |
| PostHog | Cold Build | 24m 51s | 21m 18s | 14% faster | 5.05 GB less (43.92%) |
| Storybook | Warm Build | 3m 28s | 0m 46s | 78% faster | 44.30 MB more (6.06%) |
| OpenTelemetry Java | Cold Build | 11m 21s | 10m 59s | 3% faster | 52.70 MB less (5.89%) |
| Spring AI | Cold Build | 3m 51s | 3m 58s | 3% slower | 177.45 MB less (18.84%) |
| gRPC | Cold Build | 28m 10s | 24m 38s | 13% faster | n/a |
| Zed | Cold Build | 49m 41s | 42m 50s | 14% faster | n/a |
| n8n | Cold Build | 5m 7s | 4m 55s | 4% faster | 15.86 MB more (2.13%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 44s | 2m 39s | 3% faster | 7.13 GB less (95.55%) |
| Hugo Go | Commit Build | 0m 21s | 0m 20s | near tie | 1.05 GB less (80.33%) |
| Immich | Commit Build | 0m 24s | 0m 14s | 42% faster | 7.22 GB less (77.69%) |
| Mastodon | Commit Build | 10m 9s | 9m 10s | 10% faster | 8.97 GB less (89.79%) |
| Discourse | Commit Build | 8m 34s | 2m 38s | 69% faster | 8.74 GB less (89.5%) |
| PostHog | Commit Build | 26m 30s | 14m 8s | 47% faster | 5.19 GB less (44.56%) |
| Storybook | Commit Build | 3m 18s | 3m 26s | 4% slower | 1.41 GB less (64.63%) |
| OpenTelemetry Java | Commit Build | 8m 14s | 1m 13s | 85% faster | 3.01 GB less (77.2%) |
| Spring AI | Commit Build | 1m 43s | 1m 46s | near tie | 2.59 GB less (77.16%) |
| gRPC | Commit Build | 7m 55s | 5m 40s | 28% faster | n/a |
| Zed | Commit Build | 40m 30s | 39m 8s | 3% faster | 10.71 GB less (93.57%) |
| n8n | Commit Build | 4m 19s | 4m 13s | near tie | 5.27 GB less (87.43%) |
