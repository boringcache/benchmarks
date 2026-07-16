# Latest Benchmark Report

Generated: 2026-07-16 17:04 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 10s | 18% faster | 36.28 MB less (11.96%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 14s | 10m 57s | near tie | 49.71 MB less (6.08%) |
| Spring AI | Warm Build | 0m 32s | 0m 22s | 31% faster | 176.38 MB less (18.7%) |
| gRPC | Cold Build | 25m 0s | 24m 40s | near tie | n/a |
| Zed | Warm Build | 20m 40s | 19m 17s | 7% faster | 2.13 GB less (78.15%) |
| n8n | Warm Build | 1m 28s | 0m 57s | 35% faster | 7.61 MB more (0.99%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 18s | 2m 27s | 26% faster | 1.18 GB less (77.73%) |
| Hugo Go | Commit Build | 1m 39s | 0m 50s | 49% faster | 1.01 GB less (79.5%) |
| Immich | Commit Build | 8m 53s | 5m 15s | 41% faster | 6.75 GB less (71.8%) |
| Mastodon | Commit Build | 10m 25s | 9m 35s | investigation only | 8.89 GB less (89.6%) |
| Mastodon Streaming | Commit Build | 0m 20s | 0m 19s | near tie | 9.80 GB less (98.98%) |
| Discourse | Commit Build | 3m 30s | 3m 19s | 5% faster | 8.91 GB less (89.63%) |
| Discourse Base Deps | Commit Build | 0m 12s | 0m 11s | near tie | 9.25 GB less (92.95%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 12s | near tie | 8.55 GB less (85.91%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 8s | near tie | 8.46 GB less (84.92%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 10s | near tie | 8.01 GB less (80.43%) |
| PostHog | Commit Build | 24m 21s | 18m 39s | 23% faster | 6.84 GB less (49.13%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 1m 22s | 1m 5s | 21% faster | 3.24 GB less (80.68%) |
| Spring AI | Commit Build | 3m 50s | 3m 44s | near tie | 3.22 GB less (70.37%) |
| gRPC | Commit Build | 2m 9s | 0m 32s | 75% faster | n/a |
| Zed | Commit Build | 41m 0s | 41m 45s | near tie | 10.55 GB less (92.28%) |
| n8n | Commit Build | 4m 28s | 3m 1s | 32% faster | 7.08 GB less (90.08%) |
| n8n Docker | Commit Build | 6m 52s | 7m 10s | 4% slower | n/a |
| n8n Runners | Commit Build | 1m 51s | 0m 51s | 54% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 1s | 1m 51s | 8% faster | n/a |
