# Latest Benchmark Report

Generated: 2026-05-20 13:29 UTC

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
| OpenTelemetry Java | Workflow Total | 11m 37s | 11m 24s | near tie | 50.52 MB less (6.0%) |
| Spring AI | Warm Build | 0m 32s | 0m 25s | 22% faster | 177.30 MB less (18.7%) |
| gRPC | Cold Build | 28m 10s | 24m 38s | 13% faster | n/a |
| Zed | Cold Build | 49m 41s | 42m 50s | 14% faster | n/a |
| n8n | Cold Build | 5m 7s | 4m 55s | 4% faster | 15.86 MB more (2.13%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 9s | 0m 7s | near tie | 6.78 GB less (95.33%) |
| Hugo Go | Workflow Total | 0m 38s | 0m 33s | near tie | 1.07 GB less (80.6%) |
| Immich | Commit Build | 6m 38s | 4m 26s | 33% faster | 7.65 GB less (77.56%) |
| Mastodon | Commit Build | 2m 11s | 1m 56s | 11% faster | 8.96 GB less (89.79%) |
| Discourse | Commit Build | 0m 14s | 0m 14s | near tie | 8.93 GB less (89.58%) |
| PostHog | Workflow Total | 22m 5s | 15m 23s | 30% faster | 7.18 GB less (52.69%) |
| Storybook | Commit Build | 3m 16s | 3m 31s | 8% slower | 1.26 GB less (62.45%) |
| OpenTelemetry Java | Workflow Total | 2m 7s | 1m 20s | 37% faster | 2.90 GB less (78.86%) |
| Spring AI | Workflow Total | 1m 52s | 1m 39s | 12% faster | 2.57 GB less (77.32%) |
| gRPC | Commit Build | 7m 50s | 6m 27s | 18% faster | n/a |
| Zed | Commit Build | 43m 6s | 38m 37s | 10% faster | 4.98 GB less (86.92%) |
| n8n | Workflow Total | 5m 16s | 4m 46s | 9% faster | 4.72 GB less (86.18%) |
