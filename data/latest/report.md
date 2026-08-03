# Latest Benchmark Report

Generated: 2026-08-03 09:12 UTC

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
| Hugo | Commit Build | 3m 18s | 2m 52s | 13% faster | 80.31 MB less (18.77%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 0m 15s | 0m 9s | 40% faster | 7.11 GB less (71.18%) |
| Mastodon | Commit Build | 2m 47s | 1m 35s | 43% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 13s | near tie | n/a |
| Discourse | Commit Build | 7m 51s | 4m 34s | investigation only | 8.84 GB less (89.54%) |
| Discourse Base Deps | Commit Build | 0m 14s | 0m 7s | 50% faster | 9.17 GB less (92.89%) |
| Discourse Web-Only Image | Commit Build | 0m 9s | 0m 21s | 133% slower | 8.55 GB less (86.62%) |
| Discourse Release Image | Commit Build | 0m 13s | 0m 17s | near tie | 8.45 GB less (85.62%) |
| Discourse Test Image | Commit Build | 8m 20s | 5m 41s | investigation only | 7.92 GB less (80.25%) |
| PostHog | Commit Build | 14m 10s | 12m 42s | 10% faster | n/a |
| Storybook | Commit Build | 4m 15s | 3m 48s | 11% faster | 1.64 GB less (55.51%) |
| OpenTelemetry Java | Commit Build | 1m 17s | 1m 16s | near tie | 852.61 MB less (42.99%) |
| Spring AI | Commit Build | 4m 23s | 2m 33s | 42% faster | 192.29 MB more (20.39%) |
| gRPC | Commit Build | 0m 44s | 1m 46s | 141% slower | 1.71 GB more (363.56%) |
| Duckgres | Commit Build | 4m 15s | 3m 21s | 21% faster | n/a |
| Chroma | Commit Build | 17m 14s | 10m 51s | 37% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 5m 54s | 4m 1s | 32% faster | n/a |
| n8n | Commit Build | 1m 47s | 1m 30s | 16% faster | 1.87 GB less (40.79%) |
| n8n Docker | Commit Build | 4m 46s | 3m 35s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 15s | 0m 54s | 28% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 20s | 1m 18s | 44% faster | n/a |
