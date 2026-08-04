# Latest Benchmark Report

Generated: 2026-08-04 21:56 UTC

Coverage: 23 benchmarks; fresh 10/23, rolling 23/23.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 26s | 1m 13s | 15% faster | 159.20 MB less (52.43%) |
| Storybook | Cold Build | 5m 50s | 4m 29s | 23% faster | 15.57 MB less (1.16%) |
| OpenTelemetry Java | Warm Build | 0m 58s | 0m 50s | 14% faster | 3.04 MB less (0.36%) |
| Spring AI | Cold Build | 4m 45s | 4m 52s | near tie | 4.91 MB more (0.52%) |
| gRPC | Cold Build | 25m 18s | 16m 50s | 33% faster | 829.88 MB more (805.66%) |
| Duckgres | Cold Build | 5m 20s | 3m 28s | 35% faster | n/a |
| Chroma | Cold Build | 31m 14s | 16m 7s | 48% faster | n/a |
| Linkerd2 Web | Warm Build | 0m 4s | 0m 3s | near tie | n/a |
| Qdrant | Cold Build | 12m 58s | 9m 29s | 27% faster | n/a |
| n8n | Warm Build | 1m 35s | 1m 14s | 22% faster | 11.03 MB less (1.42%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| Immich | Commit Build | 0m 24s | 0m 11s | 54% faster | 6.90 GB less (70.56%) |
| Mastodon | Commit Build | 2m 38s | 1m 30s | 43% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 24s | 0m 19s | near tie | n/a |
| Discourse | Commit Build | 3m 56s | 3m 9s | 20% faster | 8.87 GB less (89.57%) |
| Discourse Base Deps | Commit Build | 0m 16s | 0m 9s | 44% faster | 9.19 GB less (92.9%) |
| Discourse Web-Only Image | Commit Build | 0m 17s | 0m 8s | 53% faster | 8.58 GB less (86.65%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 8s | near tie | 8.83 GB less (86.15%) |
| Discourse Test Image | Commit Build | 0m 11s | 0m 9s | near tie | 7.95 GB less (80.29%) |
| PostHog | Commit Build | 22m 8s | 14m 55s | 33% faster | n/a |
| Storybook | Commit Build | 3m 58s | 3m 25s | 14% faster | 1.81 GB less (57.58%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 0m 55s | 0m 54s | near tie | 1.09 GB less (40.85%) |
| gRPC | Commit Build | 18m 17s | 14m 13s | 22% faster | 1.64 GB more (316.69%) |
| Duckgres | Commit Build | 6m 3s | 3m 23s | 44% faster | n/a |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 11s | 0m 11s | near tie | n/a |
| Qdrant | Commit Build | 11m 36s | 8m 34s | 26% faster | n/a |
| n8n | Commit Build | 1m 45s | 1m 38s | 7% faster | 3.24 GB less (52.0%) |
| n8n Docker | Commit Build | 4m 23s | 3m 2s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 5s | 0m 42s | 35% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 53s | 1m 8s | 40% faster | n/a |
