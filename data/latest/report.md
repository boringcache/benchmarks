# Latest Benchmark Report

Generated: 2026-08-02 20:55 UTC

Coverage: 24 benchmarks; fresh 11/24, rolling 24/24.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 26s | 1m 13s | 15% faster | 159.20 MB less (52.43%) |
| Storybook | Cold Build | 5m 50s | 4m 29s | 23% faster | 15.57 MB less (1.16%) |
| OpenTelemetry Java | Warm Build | 0m 58s | 0m 50s | 14% faster | 3.04 MB less (0.36%) |
| Spring AI | Cold Build | 4m 45s | 4m 52s | near tie | 4.91 MB more (0.52%) |
| gRPC | Cold Build | 25m 18s | 16m 50s | 33% faster | 829.88 MB more (805.66%) |
| Zed | Cold Build | 55m 47s | 44m 2s | 21% faster | 353.05 MB more (12.59%) |
| Duckgres | Warm Build | 0m 3s | 0m 2s | near tie | n/a |
| Chroma | Cold Build | 35m 33s | 16m 23s | 54% faster | n/a |
| Linkerd2 Web | Cold Build | 5m 18s | 3m 8s | 41% faster | n/a |
| Qdrant | Cold Build | 13m 5s | 10m 12s | 22% faster | n/a |
| n8n | Warm Build | 1m 35s | 1m 14s | 22% faster | 11.03 MB less (1.42%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 18s | 2m 52s | 13% faster | 80.31 MB less (18.77%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 0m 15s | 0m 9s | 40% faster | 7.11 GB less (71.18%) |
| Mastodon | Commit Build | 2m 47s | 1m 35s | 43% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 13s | near tie | n/a |
| Discourse | Commit Build | 5m 47s | 4m 38s | investigation only | 8.88 GB less (89.58%) |
| Discourse Base Deps | Commit Build | 8m 4s | 5m 5s | investigation only | n/a |
| Discourse Web-Only Image | Commit Build | 12m 22s | 7m 58s | investigation only | n/a |
| Discourse Release Image | Commit Build | 11m 16s | 9m 40s | investigation only | n/a |
| Discourse Test Image | Commit Build | 7m 56s | 6m 18s | investigation only | n/a |
| PostHog | Commit Build | 36m 54s | 16m 20s | investigation only | n/a |
| Storybook | Commit Build | 2m 10s | 2m 11s | near tie | 1.61 GB less (55.1%) |
| OpenTelemetry Java | Commit Build | 1m 17s | 1m 16s | near tie | 852.61 MB less (42.99%) |
| Spring AI | Commit Build | 4m 23s | 2m 33s | 42% faster | 192.29 MB more (20.39%) |
| gRPC | Commit Build | 0m 44s | 1m 46s | 141% slower | 1.71 GB more (363.56%) |
| Zed | Commit Build | 20m 1s | 19m 10s | 4% faster | 354.92 MB more (9.28%) |
| Duckgres | Commit Build | 4m 15s | 3m 21s | 21% faster | n/a |
| Chroma | Commit Build | 17m 14s | 10m 51s | 37% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 4m 35s | 3m 35s | 22% faster | n/a |
| n8n | Commit Build | 2m 6s | 2m 14s | 6% slower | 1.74 GB less (38.6%) |
| n8n Docker | Commit Build | 4m 12s | 2m 45s | 35% faster | n/a |
| n8n Runners | Commit Build | 0m 55s | 0m 38s | 31% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 13s | 1m 21s | 39% faster | n/a |
