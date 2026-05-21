# Latest Benchmark Report

Generated: 2026-05-21 09:14 UTC

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
| Hugo | Commit Build | 3m 0s | 2m 44s | 9% faster | 7.05 GB less (95.5%) |
| Hugo Go | Commit Build | 0m 47s | 0m 46s | near tie | 1.13 GB less (81.38%) |
| Immich | Commit Build | 3m 12s | 2m 48s | 13% faster | 7.53 GB less (78.4%) |
| Mastodon | Commit Build | 2m 5s | 1m 52s | 10% faster | 8.91 GB less (89.73%) |
| Discourse | Commit Build | 3m 1s | 2m 43s | 10% faster | 8.93 GB less (89.58%) |
| PostHog | Commit Build | 17m 34s | 14m 39s | 17% faster | 3.20 GB less (33.21%) |
| Storybook | Commit Build | 2m 46s | 2m 42s | near tie | 1.35 GB less (63.78%) |
| OpenTelemetry Java | Commit Build | 8m 14s | 1m 13s | 85% faster | 3.01 GB less (77.2%) |
| Spring AI | Commit Build | 0m 59s | 1m 3s | 7% slower | 2.59 GB less (77.16%) |
| gRPC | Commit Build | 0m 54s | 0m 53s | near tie | n/a |
| Zed | Commit Build | 35m 47s | 34m 48s | near tie | 10.67 GB less (93.55%) |
| n8n | Commit Build | 3m 15s | 2m 56s | 10% faster | 5.06 GB less (86.98%) |
