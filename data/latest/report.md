# Latest Benchmark Report

Generated: 2026-08-04 01:10 UTC

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
| Discourse | Commit Build | 3m 48s | 2m 30s | 34% faster | 8.92 GB less (89.63%) |
| Discourse Base Deps | Commit Build | 0m 17s | 0m 13s | near tie | 9.25 GB less (92.95%) |
| Discourse Web-Only Image | Commit Build | 0m 17s | 0m 7s | 59% faster | 8.63 GB less (86.73%) |
| Discourse Release Image | Commit Build | 0m 21s | 0m 15s | 29% faster | 8.53 GB less (85.73%) |
| Discourse Test Image | Commit Build | 0m 11s | 0m 7s | near tie | 8.00 GB less (80.4%) |
| PostHog | Commit Build | 25m 21s | 14m 46s | 42% faster | n/a |
| Storybook | Commit Build | 3m 39s | 3m 42s | near tie | 1.70 GB less (56.0%) |
| OpenTelemetry Java | Commit Build | 2m 32s | 2m 43s | 7% slower | 852.33 MB less (42.96%) |
| Spring AI | Commit Build | 1m 21s | 1m 31s | 12% slower | 1.09 GB less (48.35%) |
| gRPC | Commit Build | 0m 40s | 0m 53s | 33% slower | 1.65 GB more (332.21%) |
| Duckgres | Commit Build | 5m 16s | 3m 18s | 37% faster | n/a |
| Chroma | Commit Build | 21m 11s | 11m 32s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 2m 5s | 2m 19s | 11% slower | n/a |
| Qdrant | Commit Build | 4m 37s | 4m 0s | 13% faster | n/a |
| n8n | Commit Build | 3m 47s | 3m 38s | 4% faster | 2.34 GB less (43.24%) |
| n8n Docker | Commit Build | 4m 15s | 3m 11s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 12s | 0m 45s | 38% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 16s | 1m 25s | 38% faster | n/a |
