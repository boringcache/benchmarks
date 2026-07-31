# Latest Benchmark Report

Generated: 2026-07-31 17:13 UTC

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
| Zed | Cold Build | 55m 35s | 56m 22s | near tie | 7.54 MB less (0.27%) |
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
| Immich | Commit Build | 0m 19s | 0m 7s | 63% faster | 7.11 GB less (71.18%) |
| Mastodon | Commit Build | 2m 47s | 1m 35s | 43% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 13s | near tie | n/a |
| Discourse | Commit Build | 4m 23s | 2m 42s | 38% faster | 8.90 GB less (89.61%) |
| Discourse Base Deps | Commit Build | 0m 14s | 0m 7s | 50% faster | 9.23 GB less (92.93%) |
| Discourse Web-Only Image | Commit Build | 0m 10s | 0m 8s | near tie | 8.62 GB less (86.71%) |
| Discourse Release Image | Commit Build | 0m 17s | 0m 10s | 41% faster | 8.52 GB less (85.71%) |
| Discourse Test Image | Commit Build | 0m 25s | 0m 11s | 56% faster | 7.99 GB less (80.37%) |
| PostHog | Commit Build | 28m 3s | 14m 38s | 48% faster | n/a |
| Storybook | Commit Build | 3m 39s | 3m 38s | near tie | 1.46 GB less (52.89%) |
| OpenTelemetry Java | Commit Build | 2m 17s | 2m 29s | 9% slower | 851.63 MB less (42.96%) |
| Spring AI | Commit Build | 4m 23s | 2m 33s | 42% faster | 192.29 MB more (20.39%) |
| gRPC | Commit Build | 7m 47s | 4m 31s | 42% faster | 1.68 GB more (431.14%) |
| Zed | Commit Build | 34m 29s | 32m 32s | 6% faster | 8.11 GB less (72.6%) |
| Duckgres | Commit Build | 4m 21s | 3m 21s | 23% faster | n/a |
| Chroma | Commit Build | 18m 8s | 10m 55s | 40% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 5m 2s | 4m 12s | 17% faster | n/a |
| n8n | Commit Build | 3m 36s | 3m 25s | 5% faster | 1.53 GB less (34.76%) |
| n8n Docker | Commit Build | 4m 16s | 3m 0s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 44s | 19% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 22s | 1m 43s | 27% faster | n/a |
