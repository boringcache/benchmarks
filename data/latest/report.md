# Latest Benchmark Report

Generated: 2026-05-20 17:43 UTC

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
| OpenTelemetry Java | Cold Build | 11m 8s | 11m 7s | near tie | 50.52 MB less (6.0%) |
| Spring AI | Warm Build | 0m 32s | 0m 25s | 22% faster | 177.30 MB less (18.7%) |
| gRPC | Cold Build | 28m 10s | 24m 38s | 13% faster | n/a |
| Zed | Cold Build | 49m 41s | 42m 50s | 14% faster | n/a |
| n8n | Cold Build | 5m 7s | 4m 55s | 4% faster | 15.86 MB more (2.13%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 9s | 0m 7s | near tie | 6.78 GB less (95.33%) |
| Hugo Go | Commit Build | 0m 21s | 0m 20s | near tie | 1.07 GB less (80.6%) |
| Immich | Commit Build | 5m 31s | 4m 46s | 14% faster | 7.87 GB less (79.15%) |
| Mastodon | Commit Build | 2m 56s | 1m 58s | 33% faster | 8.87 GB less (89.7%) |
| Discourse | Commit Build | 3m 22s | 2m 55s | 13% faster | 9.16 GB less (89.81%) |
| PostHog | Commit Build | 23m 4s | 12m 58s | 44% faster | 5.25 GB less (44.86%) |
| Storybook | Commit Build | 4m 16s | 3m 31s | 18% faster | 1.29 GB less (63.06%) |
| OpenTelemetry Java | Commit Build | 5m 7s | 5m 4s | near tie | 2.93 GB less (79.03%) |
| Spring AI | Commit Build | 3m 16s | 3m 9s | 4% faster | 2.57 GB less (77.32%) |
| gRPC | Commit Build | 7m 50s | 6m 27s | 18% faster | n/a |
| Zed | Commit Build | 18m 14s | 18m 8s | near tie | 10.62 GB less (93.52%) |
| n8n | Commit Build | 4m 44s | 5m 36s | 18% slower | 4.91 GB less (86.65%) |
