# Latest Benchmark Report

Generated: 2026-07-30 13:08 UTC

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
| Immich | Commit Build | 6m 42s | 2m 27s | 63% faster | 764.60 MB less (20.59%) |
| Mastodon | Commit Build | 2m 53s | 1m 42s | 41% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 31s | 0m 15s | 52% faster | n/a |
| Discourse | Commit Build | 4m 7s | 2m 34s | 38% faster | 8.62 GB less (89.3%) |
| Discourse Base Deps | Commit Build | 0m 17s | 0m 30s | 76% slower | 9.29 GB less (92.98%) |
| Discourse Web-Only Image | Commit Build | 0m 17s | 0m 11s | 35% faster | 8.68 GB less (86.79%) |
| Discourse Release Image | Commit Build | 0m 11s | 0m 9s | near tie | 8.58 GB less (85.79%) |
| Discourse Test Image | Commit Build | 0m 17s | 0m 12s | near tie | 8.05 GB less (80.49%) |
| PostHog | Commit Build | 23m 48s | 14m 7s | 41% faster | n/a |
| Storybook | Commit Build | 3m 56s | 3m 47s | 4% faster | 913.86 MB less (40.93%) |
| OpenTelemetry Java | Commit Build | 9m 55s | 6m 48s | 31% faster | 650.84 MB less (37.15%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 18m 10s | 13m 53s | 24% faster | 1.62 GB more (546.78%) |
| Zed | Commit Build | 59m 6s | 40m 50s | 31% faster | 11.95 GB more (437.2%) |
| Duckgres | Commit Build | 4m 25s | 3m 24s | 23% faster | n/a |
| Chroma | Commit Build | 17m 51s | 11m 13s | 37% faster | n/a |
| Linkerd2 Web | Commit Build | 2m 20s | 1m 54s | 19% faster | n/a |
| Qdrant | Commit Build | 9m 35s | 9m 7s | 5% faster | n/a |
| n8n | Commit Build | 2m 2s | 2m 41s | 32% slower | 221.31 MB less (7.36%) |
| n8n Docker | Commit Build | 4m 0s | 3m 0s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 17s | 0m 54s | 30% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 47s | 1m 30s | 16% faster | n/a |
