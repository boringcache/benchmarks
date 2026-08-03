# Latest Benchmark Report

Generated: 2026-08-03 19:55 UTC

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
| Immich | Commit Build | 4m 16s | 2m 24s | 44% faster | 6.56 GB less (69.5%) |
| Mastodon | Commit Build | 3m 40s | 1m 38s | 55% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 14s | 0m 11s | near tie | n/a |
| Discourse | Commit Build | 3m 23s | 2m 32s | 25% faster | 8.45 GB less (89.11%) |
| Discourse Base Deps | Commit Build | 0m 17s | 0m 8s | 53% faster | 9.64 GB less (93.21%) |
| Discourse Web-Only Image | Commit Build | 0m 14s | 0m 11s | near tie | 9.03 GB less (87.23%) |
| Discourse Release Image | Commit Build | 0m 22s | 0m 9s | 59% faster | 8.93 GB less (86.27%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 12s | near tie | 8.40 GB less (81.15%) |
| PostHog | Commit Build | 24m 27s | 14m 33s | 40% faster | n/a |
| Storybook | Commit Build | 3m 39s | 3m 42s | near tie | 1.70 GB less (56.0%) |
| OpenTelemetry Java | Commit Build | 2m 32s | 2m 43s | 7% slower | 852.33 MB less (42.96%) |
| Spring AI | Commit Build | 1m 21s | 1m 31s | 12% slower | 1.09 GB less (48.35%) |
| gRPC | Commit Build | 0m 44s | 1m 46s | 141% slower | 1.71 GB more (363.56%) |
| Duckgres | Commit Build | 4m 26s | 3m 51s | 13% faster | n/a |
| Chroma | Commit Build | 17m 14s | 10m 51s | 37% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 4m 37s | 4m 0s | 13% faster | n/a |
| n8n | Commit Build | 4m 12s | 3m 31s | 16% faster | 2.28 GB less (42.93%) |
| n8n Docker | Commit Build | 4m 50s | 2m 57s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 58s | 0m 39s | 33% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 16s | 1m 27s | 36% faster | n/a |
