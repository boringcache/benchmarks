# Latest Benchmark Report

Generated: 2026-08-03 14:52 UTC

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
| Immich | Commit Build | 4m 30s | 2m 22s | 47% faster | 7.07 GB less (71.05%) |
| Mastodon | Commit Build | 3m 14s | 2m 42s | 16% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 30s | 0m 14s | 53% faster | n/a |
| Discourse | Commit Build | 5m 46s | 5m 19s | investigation only | 8.88 GB less (89.59%) |
| Discourse Base Deps | Commit Build | 0m 8s | 0m 14s | 75% slower | 9.21 GB less (92.92%) |
| Discourse Web-Only Image | Commit Build | 0m 15s | 0m 12s | near tie | 8.59 GB less (86.68%) |
| Discourse Release Image | Commit Build | 0m 15s | 0m 9s | 40% faster | 8.50 GB less (85.68%) |
| Discourse Test Image | Commit Build | 10m 38s | 6m 56s | investigation only | 9.64 GB less (83.17%) |
| PostHog | Commit Build | 22m 2s | 0m 21s | 98% faster | n/a |
| Storybook | Commit Build | 4m 20s | 3m 59s | 8% faster | 1.67 GB less (56.01%) |
| OpenTelemetry Java | Commit Build | 1m 17s | 1m 16s | near tie | 852.61 MB less (42.99%) |
| Spring AI | Commit Build | 1m 25s | 1m 27s | near tie | 924.97 MB less (47.97%) |
| gRPC | Commit Build | 0m 44s | 1m 46s | 141% slower | 1.71 GB more (363.56%) |
| Duckgres | Commit Build | 4m 16s | 3m 20s | 22% faster | n/a |
| Chroma | Commit Build | 17m 14s | 10m 51s | 37% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 5m 18s | 3m 39s | 31% faster | n/a |
| n8n | Commit Build | 3m 8s | 3m 22s | 7% slower | 2.10 GB less (42.29%) |
| n8n Docker | Commit Build | 4m 27s | 3m 10s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 55s | 0m 44s | 20% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 7s | 1m 16s | 40% faster | n/a |
