# Latest Benchmark Report

Generated: 2026-05-20 05:57 UTC

Coverage: 12 benchmarks; fresh 12/12, rolling 12/12.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 44s | 3m 31s | 6% faster | 6.78 GB less (95.33%) |
| Hugo Go | Cold Build | 1m 16s | 1m 27s | 14% slower | 40.39 MB less (13.73%) |
| Immich | Cold Build | 6m 34s | 4m 28s | 32% faster | 7.60 GB less (77.44%) |
| Mastodon | Cold Build | 9m 24s | 9m 5s | 3% faster | 9.75 GB less (90.4%) |
| Discourse | Workflow Total | 6m 37s | 5m 38s | 15% faster | 8.99 GB less (89.64%) |
| PostHog | Cold Build | 23m 0s | 15m 31s | 33% faster | 2.94 GB less (31.35%) |
| Storybook | Warm Build | 3m 28s | 0m 46s | 78% faster | 44.30 MB more (6.06%) |
| OpenTelemetry Java | Cold Build | 9m 12s | 10m 45s | 17% slower | 50.53 MB less (6.0%) |
| Spring AI | Warm Build | 0m 38s | 0m 29s | 24% faster | 177.27 MB less (18.7%) |
| gRPC | Warm Build | 32m 11s | 0m 45s | 98% faster | n/a |
| Zed | Cold Build | 50m 54s | 49m 25s | near tie | 2.05 GB less (73.59%) |
| n8n | Cold Build | 5m 4s | 5m 9s | near tie | 15.87 MB more (2.14%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 10s | 0m 8s | near tie | 6.78 GB less (95.33%) |
| Hugo Go | Commit Build | 0m 31s | 1m 14s | 139% slower | 1.39 GB less (84.38%) |
| Immich | Commit Build | 0m 9s | 0m 8s | near tie | 7.39 GB less (76.96%) |
| Mastodon | Commit Build | 0m 22s | 0m 14s | 36% faster | 9.37 GB less (90.06%) |
| Discourse | Commit Build | 3m 33s | 2m 58s | 16% faster | 8.59 GB less (89.21%) |
| PostHog | Commit Build | 24m 53s | 15m 19s | cache import unavailable | 5.11 GB less (44.19%) |
| Storybook | Workflow Total | 3m 52s | 3m 20s | 14% faster | 1.24 GB less (62.15%) |
| OpenTelemetry Java | Workflow Total | 4m 42s | 4m 26s | 6% faster | 2.89 GB less (78.85%) |
| Spring AI | Commit Build | 0m 46s | 3m 20s | 335% slower | 2.57 GB less (77.32%) |
| gRPC | Workflow Total | 1m 16s | 1m 5s | 14% faster | n/a |
| Zed | Workflow Total | 41m 37s | 38m 54s | 7% faster | 10.72 GB less (93.47%) |
| n8n | Commit Build | 3m 37s | 1m 3s | 71% faster | 4.54 GB less (85.7%) |
