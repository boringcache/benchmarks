# Latest Benchmark Report

Generated: 2026-07-28 09:31 UTC

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
| n8n | Cold Build | 3m 53s | 4m 0s | 3% slower | 9.49 MB less (1.22%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 5s | 2m 56s | 5% faster | 5.97 GB less (94.62%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 0m 17s | 0m 9s | 47% faster | 6.59 GB less (69.57%) |
| Mastodon | Commit Build | 2m 12s | 1m 39s | 25% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 14s | 0m 7s | 50% faster | n/a |
| Discourse | Commit Build | 4m 7s | 2m 16s | 45% faster | 8.82 GB less (89.52%) |
| Discourse Base Deps | Commit Build | 0m 17s | 0m 9s | 47% faster | 9.61 GB less (93.19%) |
| Discourse Web-Only Image | Commit Build | 0m 13s | 0m 8s | near tie | 8.99 GB less (87.19%) |
| Discourse Release Image | Commit Build | 0m 20s | 0m 12s | 40% faster | 8.89 GB less (86.22%) |
| Discourse Test Image | Commit Build | 0m 11s | 0m 37s | 236% slower | 8.36 GB less (81.08%) |
| PostHog | Commit Build | 26m 30s | 13m 58s | 47% faster | n/a |
| Storybook | Commit Build | 2m 51s | 3m 10s | 11% slower | 1.19 GB less (58.19%) |
| OpenTelemetry Java | Commit Build | 5m 52s | 5m 33s | 5% faster | 2.28 GB less (77.95%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 1m 45s | 0m 41s | 61% faster | 4.85 GB less (74.89%) |
| Zed | Commit Build | 19m 41s | 24m 56s | 27% slower | 3.80 GB less (59.46%) |
| Duckgres | Commit Build | 5m 38s | 3m 14s | 43% faster | n/a |
| Chroma | Commit Build | 22m 25s | 10m 56s | 51% faster | n/a |
| Linkerd2 Web | Commit Build | 3m 50s | 2m 10s | 43% faster | n/a |
| Qdrant | Commit Build | 10m 27s | 8m 37s | 18% faster | n/a |
| n8n | Commit Build | 4m 4s | 3m 38s | 11% faster | 2.06 GB less (43.62%) |
| n8n Docker | Commit Build | 5m 26s | 3m 32s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 7s | 0m 40s | 40% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 14s | 1m 11s | 47% faster | n/a |
