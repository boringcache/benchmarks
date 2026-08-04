# Latest Benchmark Report

Generated: 2026-08-04 17:14 UTC

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
| Immich | Commit Build | 0m 17s | 0m 7s | 59% faster | 6.74 GB less (70.05%) |
| Mastodon | Commit Build | 2m 38s | 1m 30s | 43% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 34s | 0m 28s | investigation only | n/a |
| Discourse | Commit Build | 3m 43s | 2m 40s | 28% faster | 8.89 GB less (89.59%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 10s | near tie | 9.57 GB less (93.16%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 6s | 60% faster | 8.95 GB less (87.14%) |
| Discourse Release Image | Commit Build | 0m 19s | 0m 9s | 53% faster | 8.48 GB less (85.65%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 9s | near tie | 8.32 GB less (81.01%) |
| PostHog | Commit Build | 23m 5s | 14m 0s | 39% faster | n/a |
| Storybook | Commit Build | 3m 58s | 3m 25s | 14% faster | 1.81 GB less (57.58%) |
| OpenTelemetry Java | Commit Build | 4m 18s | 4m 37s | 7% slower | 900.01 MB less (44.84%) |
| Spring AI | Commit Build | 2m 42s | 2m 53s | 7% slower | 1.09 GB less (40.91%) |
| gRPC | Commit Build | 0m 40s | 0m 53s | 33% slower | 1.65 GB more (332.21%) |
| Duckgres | Commit Build | 4m 25s | 3m 28s | 22% faster | n/a |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 2m 36s | 1m 15s | 52% faster | n/a |
| Qdrant | Commit Build | 11m 36s | 8m 34s | 26% faster | n/a |
| n8n | Commit Build | 4m 38s | 4m 25s | 5% faster | 3.15 GB less (50.94%) |
| n8n Docker | Commit Build | 4m 23s | 3m 40s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 58s | 0m 44s | 24% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 20s | 1m 14s | 47% faster | n/a |
