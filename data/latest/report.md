# Latest Benchmark Report

Generated: 2026-07-31 13:13 UTC

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
| Immich | Commit Build | 6m 54s | 4m 23s | 36% faster | 7.43 GB less (72.07%) |
| Mastodon | Commit Build | 2m 53s | 1m 35s | 45% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 13s | near tie | n/a |
| Discourse | Commit Build | 4m 9s | 2m 39s | 36% faster | 8.81 GB less (89.51%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 11s | near tie | 9.14 GB less (92.87%) |
| Discourse Web-Only Image | Commit Build | 0m 16s | 0m 19s | near tie | 8.52 GB less (86.58%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 9s | near tie | 8.42 GB less (85.57%) |
| Discourse Test Image | Commit Build | 0m 11s | 0m 10s | near tie | 7.89 GB less (80.18%) |
| PostHog | Commit Build | 24m 46s | 14m 24s | 42% faster | n/a |
| Storybook | Commit Build | 3m 39s | 3m 38s | near tie | 1.46 GB less (52.89%) |
| OpenTelemetry Java | Commit Build | 2m 17s | 2m 29s | 9% slower | 851.63 MB less (42.96%) |
| Spring AI | Commit Build | 4m 23s | 2m 33s | 42% faster | 192.29 MB more (20.39%) |
| gRPC | Commit Build | 7m 47s | 4m 31s | 42% faster | 1.68 GB more (431.14%) |
| Zed | Commit Build | 40m 36s | 38m 57s | 4% faster | 10.01 GB more (89.62%) |
| Duckgres | Commit Build | 4m 21s | 3m 21s | 23% faster | n/a |
| Chroma | Commit Build | 18m 8s | 10m 55s | 40% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 4m 49s | 3m 43s | 23% faster | n/a |
| n8n | Commit Build | 3m 35s | 3m 27s | 4% faster | 1.29 GB less (31.11%) |
| n8n Docker | Commit Build | 4m 31s | 3m 25s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 40s | 26% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 16s | 1m 25s | 38% faster | n/a |
