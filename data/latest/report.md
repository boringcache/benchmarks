# Latest Benchmark Report

Generated: 2026-07-28 01:04 UTC

Coverage: 24 benchmarks; fresh 11/24, rolling 24/24.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 27s | 1m 26s | near tie | 158.94 MB less (52.38%) |
| Storybook | Cold Build | 3m 33s | 3m 46s | 6% slower | 1.73 MB less (0.2%) |
| OpenTelemetry Java | Cold Build | 12m 14s | 11m 23s | 7% faster | 3.38 MB less (0.42%) |
| Spring AI | Warm Build | 0m 32s | 0m 25s | 22% faster | 5.17 MB more (0.55%) |
| gRPC | Cold Build | 32m 18s | 19m 44s | 39% faster | 818.97 MB more (802.79%) |
| Zed | Cold Build | 54m 26s | 54m 8s | near tie | 619.86 MB less (22.18%) |
| Duckgres | Warm Build | 0m 3s | 0m 2s | near tie | n/a |
| Chroma | Cold Build | 35m 33s | 16m 23s | 54% faster | n/a |
| Linkerd2 Web | Cold Build | 5m 18s | 3m 8s | 41% faster | n/a |
| Qdrant | Cold Build | 13m 5s | 10m 12s | 22% faster | n/a |
| n8n | Cold Build | 4m 3s | 3m 49s | 6% faster | 9.31 MB less (1.2%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 5s | 2m 56s | 5% faster | 5.97 GB less (94.62%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 0m 17s | 0m 9s | 47% faster | 6.59 GB less (69.57%) |
| Mastodon | Commit Build | 2m 27s | 1m 32s | 37% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 7s | near tie | n/a |
| Discourse | Commit Build | 3m 49s | 2m 45s | 28% faster | 8.52 GB less (89.19%) |
| Discourse Base Deps | Commit Build | 9m 51s | 6m 20s | investigation only | n/a |
| Discourse Web-Only Image | Commit Build | 14m 36s | 8m 21s | investigation only | n/a |
| Discourse Release Image | Commit Build | 11m 54s | 12m 7s | investigation only | n/a |
| Discourse Test Image | Commit Build | 7m 35s | 6m 18s | investigation only | n/a |
| PostHog | Commit Build | 19m 36s | 13m 36s | 31% faster | n/a |
| Storybook | Commit Build | 1m 33s | 1m 26s | 8% faster | 1.16 GB less (57.65%) |
| OpenTelemetry Java | Commit Build | 5m 52s | 5m 33s | 5% faster | 2.28 GB less (77.95%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 1m 57s | 0m 45s | 62% faster | n/a |
| Zed | Commit Build | 20m 1s | 20m 12s | near tie | 7.66 GB more (68.63%) |
| Duckgres | Commit Build | 5m 38s | 3m 14s | 43% faster | n/a |
| Chroma | Commit Build | 22m 25s | 10m 56s | 51% faster | n/a |
| Linkerd2 Web | Commit Build | 3m 50s | 2m 10s | 43% faster | n/a |
| Qdrant | Commit Build | 11m 10s | 8m 53s | 20% faster | n/a |
| n8n | Commit Build | 4m 5s | 3m 44s | 9% faster | 3.41 GB less (77.43%) |
| n8n Docker | Commit Build | 5m 16s | 2m 54s | 45% faster | n/a |
| n8n Runners | Commit Build | 1m 34s | 0m 44s | 53% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 52s | 1m 38s | 13% faster | n/a |
