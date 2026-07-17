# Latest Benchmark Report

Generated: 2026-07-17 01:05 UTC

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
| Immich | Commit Build | 0m 8s | 0m 12s | near tie | 8.44 GB less (76.29%) |
| Mastodon | Commit Build | 10m 25s | 9m 35s | investigation only | 8.89 GB less (89.6%) |
| Mastodon Streaming | Commit Build | 0m 20s | 0m 19s | near tie | 9.80 GB less (98.98%) |
| Discourse | Commit Build | 3m 15s | 3m 14s | near tie | 8.94 GB less (89.66%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 8s | near tie | 9.27 GB less (92.96%) |
| Discourse Web-Only Image | Commit Build | 0m 9s | 0m 13s | near tie | 8.57 GB less (85.94%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 11s | near tie | 8.47 GB less (84.94%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 11s | near tie | 8.03 GB less (80.46%) |
| PostHog | Commit Build | 25m 55s | 18m 32s | 28% faster | 4.90 GB less (40.9%) |
| Storybook | Commit Build | 2m 18s | 1m 32s | 33% faster | 5.51 GB less (85.37%) |
| OpenTelemetry Java | Commit Build | 4m 51s | 5m 26s | 12% slower | 3.27 GB less (80.86%) |
| Spring AI | Commit Build | 3m 50s | 3m 44s | near tie | 3.22 GB less (70.37%) |
| gRPC | Commit Build | 21m 33s | 14m 0s | 35% faster | n/a |
| Zed | Commit Build | 44m 12s | 44m 37s | near tie | 10.58 GB less (92.3%) |
| n8n | Commit Build | 4m 1s | 1m 45s | 56% faster | 14.99 GB less (95.06%) |
| n8n Docker | Commit Build | 5m 33s | 5m 40s | near tie | n/a |
| n8n Runners | Commit Build | 1m 15s | 0m 52s | 31% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 42s | 1m 25s | 17% faster | n/a |
