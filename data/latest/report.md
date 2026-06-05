# Latest Benchmark Report

Generated: 2026-06-05 01:31 UTC

Coverage: 20 benchmarks; fresh 3/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 20s | 3m 37s | 9% slower | 44.78 MB more (6.13%) |
| OpenTelemetry Java | Warm Build | 1m 0s | 0m 54s | 10% faster | 52.36 MB less (5.85%) |
| Spring AI | Warm Build | 0m 35s | 0m 28s | 20% faster | 175.44 MB less (18.42%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 8s | 2m 51s | 9% faster | 2.99 GB less (89.9%) |
| Hugo Go | Commit Build | 0m 46s | 0m 48s | near tie | 1021.01 MB less (78.21%) |
| Immich | Commit Build | 6m 13s | 4m 16s | 31% faster | 7.62 GB less (78.44%) |
| Mastodon | Commit Build | 0m 17s | 0m 10s | 41% faster | 8.96 GB less (89.92%) |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 9s | near tie | 9.86 GB less (98.99%) |
| Discourse | Commit Build | 3m 20s | 3m 7s | 7% faster | 8.95 GB less (89.77%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 13s | near tie | 9.33 GB less (93.53%) |
| Discourse Web-Only Image | Commit Build | 0m 17s | 0m 10s | 41% faster | 8.74 GB less (87.6%) |
| Discourse Release Image | Commit Build | 0m 15s | 0m 7s | 53% faster | 8.64 GB less (86.6%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 9s | near tie | 8.06 GB less (80.81%) |
| PostHog | Commit Build | 16m 7s | 12m 41s | 21% faster | 3.47 GB less (36.53%) |
| Storybook | Commit Build | 3m 59s | 3m 48s | 5% faster | 2.41 GB less (74.98%) |
| OpenTelemetry Java | Commit Build | 7m 5s | 7m 18s | 3% slower | 2.36 GB less (72.71%) |
| Spring AI | Commit Build | 2m 43s | 3m 17s | 21% slower | 2.77 GB less (74.67%) |
| gRPC | Commit Build | 1m 0s | 0m 37s | 38% faster | n/a |
| Zed | Commit Build | 41m 13s | 41m 21s | near tie | 10.85 GB less (92.91%) |
| n8n | Commit Build | 2m 53s | 1m 51s | 36% faster | 11.91 GB less (93.84%) |
| n8n Docker | Commit Build | 5m 4s | 3m 47s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 47s | 13% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 53s | 1m 28s | 22% faster | n/a |
