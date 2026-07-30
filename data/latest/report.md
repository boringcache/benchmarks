# Latest Benchmark Report

Generated: 2026-07-30 17:09 UTC

Coverage: 24 benchmarks; fresh 11/24, rolling 24/24.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 27s | 1m 32s | 6% slower | 158.94 MB less (52.38%) |
| Storybook | Cold Build | 3m 39s | 3m 32s | 3% faster | 1.44 MB less (0.16%) |
| OpenTelemetry Java | Cold Build | 11m 59s | 11m 28s | 4% faster | 3.35 MB less (0.42%) |
| Spring AI | Cold Build | 4m 21s | 4m 16s | near tie | 5.16 MB more (0.55%) |
| gRPC | Cold Build | 39m 2s | 24m 13s | 38% faster | 818.96 MB more (802.71%) |
| Zed | Cold Build | 55m 29s | 56m 19s | near tie | 8.51 MB less (0.3%) |
| Duckgres | Warm Build | 0m 3s | 0m 2s | near tie | n/a |
| Chroma | Cold Build | 35m 33s | 16m 23s | 54% faster | n/a |
| Linkerd2 Web | Cold Build | 5m 18s | 3m 8s | 41% faster | n/a |
| Qdrant | Cold Build | 13m 5s | 10m 12s | 22% faster | n/a |
| n8n | Cold Build | 3m 48s | 3m 58s | 4% slower | 9.29 MB less (1.2%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 18s | 2m 52s | 13% faster | 80.31 MB less (18.77%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 0m 19s | 0m 13s | 32% faster | 1.83 GB less (38.9%) |
| Mastodon | Commit Build | 2m 17s | 2m 19s | near tie | n/a |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 6s | near tie | n/a |
| Discourse | Commit Build | 4m 12s | 2m 36s | 38% faster | 8.97 GB less (89.68%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 8s | near tie | 9.30 GB less (92.98%) |
| Discourse Web-Only Image | Commit Build | 0m 8s | 0m 11s | near tie | 8.68 GB less (86.79%) |
| Discourse Release Image | Commit Build | 0m 23s | 0m 8s | 65% faster | 8.58 GB less (85.8%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 10s | near tie | 8.05 GB less (80.5%) |
| PostHog | Commit Build | 21m 9s | 15m 41s | 26% faster | n/a |
| Storybook | Commit Build | 3m 17s | 4m 37s | 41% slower | 1.35 GB less (51.06%) |
| OpenTelemetry Java | Commit Build | 1m 15s | 3m 59s | 219% slower | 851.66 MB less (42.99%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 18m 10s | 13m 53s | 24% faster | 1.62 GB more (546.78%) |
| Zed | Commit Build | 23m 22s | 23m 1s | near tie | 6.96 GB more (69.7%) |
| Duckgres | Commit Build | 4m 14s | 3m 24s | 20% faster | n/a |
| Chroma | Commit Build | 17m 51s | 11m 13s | 37% faster | n/a |
| Linkerd2 Web | Commit Build | 2m 20s | 1m 54s | 19% faster | n/a |
| Qdrant | Commit Build | 9m 35s | 9m 7s | 5% faster | n/a |
| n8n | Commit Build | 3m 8s | 3m 3s | near tie | 535.58 MB less (16.03%) |
| n8n Docker | Commit Build | 5m 20s | 2m 46s | 48% faster | n/a |
| n8n Runners | Commit Build | 0m 55s | 0m 58s | near tie | n/a |
| n8n Runners Distroless | Commit Build | 1m 44s | 1m 32s | 12% faster | n/a |
