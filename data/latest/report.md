# Latest Benchmark Report

Generated: 2026-07-14 17:00 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 10s | 18% faster | 36.28 MB less (11.96%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 29s | 10m 55s | 5% faster | 49.73 MB less (6.09%) |
| Spring AI | Warm Build | 0m 34s | 0m 27s | 21% faster | 176.12 MB less (17.96%) |
| gRPC | Cold Build | 25m 0s | 24m 40s | near tie | n/a |
| Zed | Warm Build | 20m 40s | 19m 17s | 7% faster | 2.13 GB less (78.15%) |
| n8n | Warm Build | 1m 28s | 0m 57s | 35% faster | 7.61 MB more (0.99%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 18s | 2m 27s | 26% faster | 1.18 GB less (77.73%) |
| Hugo Go | Commit Build | 1m 39s | 0m 50s | 49% faster | 1.01 GB less (79.5%) |
| Immich | Commit Build | 5m 20s | 4m 54s | 8% faster | 7.12 GB less (73.01%) |
| Mastodon | Commit Build | 2m 35s | 1m 56s | 25% faster | 8.93 GB less (89.62%) |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 8s | near tie | 10.21 GB less (99.02%) |
| Discourse | Commit Build | 3m 56s | 3m 0s | 24% faster | 8.71 GB less (89.41%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 12s | near tie | 8.87 GB less (92.66%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 20s | 150% slower | 8.25 GB less (86.21%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 16s | 100% slower | 8.15 GB less (85.17%) |
| Discourse Test Image | Commit Build | 0m 11s | 0m 11s | near tie | 7.62 GB less (79.64%) |
| PostHog | Commit Build | 20m 44s | 18m 36s | 10% faster | 2.81 GB less (28.79%) |
| Storybook | Commit Build | 4m 21s | 3m 20s | 23% faster | 5.43 GB less (85.18%) |
| OpenTelemetry Java | Commit Build | 1m 29s | 0m 57s | 36% faster | 3.14 GB less (80.42%) |
| Spring AI | Commit Build | 3m 30s | 3m 33s | near tie | 3.22 GB less (70.39%) |
| gRPC | Commit Build | 2m 25s | 0m 33s | 77% faster | n/a |
| Zed | Commit Build | 43m 26s | 43m 53s | near tie | 10.58 GB less (92.31%) |
| n8n | Commit Build | 5m 40s | 3m 47s | 33% faster | 13.18 GB less (94.43%) |
| n8n Docker | Commit Build | 5m 48s | 5m 8s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 17s | 0m 56s | 27% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 45s | 1m 37s | 41% faster | n/a |
