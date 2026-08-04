# Latest Benchmark Report

Generated: 2026-08-04 09:35 UTC

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
| Hugo | Commit Build | 3m 12s | 3m 1s | 6% faster | 712.66 MB less (67.22%) |
| Hugo Go | Commit Build | 1m 24s | 1m 15s | 11% faster | 160.72 MB less (52.67%) |
| Immich | Commit Build | 4m 57s | 2m 9s | 57% faster | 7.11 GB less (71.16%) |
| Mastodon | Commit Build | 3m 40s | 1m 38s | 55% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 14s | 0m 11s | near tie | n/a |
| Discourse | Commit Build | 4m 4s | 2m 46s | 32% faster | 8.94 GB less (89.64%) |
| Discourse Base Deps | Commit Build | 0m 15s | 0m 9s | 40% faster | 9.62 GB less (93.2%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 6s | 60% faster | 9.00 GB less (87.2%) |
| Discourse Release Image | Commit Build | 0m 19s | 0m 9s | 53% faster | 8.90 GB less (86.24%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 6s | 57% faster | 8.37 GB less (81.1%) |
| PostHog | Commit Build | 23m 18s | 13m 54s | 40% faster | n/a |
| Storybook | Commit Build | 1m 38s | 1m 27s | 11% faster | 1.72 GB less (56.35%) |
| OpenTelemetry Java | Commit Build | 2m 32s | 2m 43s | 7% slower | 852.33 MB less (42.96%) |
| Spring AI | Commit Build | 1m 21s | 1m 31s | 12% slower | 1.09 GB less (48.35%) |
| gRPC | Commit Build | 0m 40s | 0m 53s | 33% slower | 1.65 GB more (332.21%) |
| Duckgres | Commit Build | 6m 13s | 3m 23s | 46% faster | n/a |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 2m 36s | 1m 15s | 52% faster | n/a |
| Qdrant | Commit Build | 11m 2s | 7m 50s | 29% faster | n/a |
| n8n | Commit Build | 3m 19s | 3m 16s | near tie | 2.66 GB less (46.69%) |
| n8n Docker | Commit Build | 4m 15s | 3m 18s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 14s | 0m 39s | 47% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 45s | 1m 13s | 30% faster | n/a |
