# Latest Benchmark Report

Generated: 2026-07-31 09:39 UTC

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
| Immich | Commit Build | 0m 11s | 3m 27s | 1782% slower | 5.49 GB less (65.58%) |
| Mastodon | Commit Build | 2m 58s | 2m 14s | 25% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 34s | 0m 23s | investigation only | n/a |
| Discourse | Commit Build | 6m 50s | 4m 44s | investigation only | 8.95 GB less (89.66%) |
| Discourse Base Deps | Commit Build | 0m 23s | 0m 10s | 57% faster | 9.25 GB less (92.95%) |
| Discourse Web-Only Image | Commit Build | 0m 18s | 0m 10s | 44% faster | 8.64 GB less (86.73%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 8s | near tie | 8.54 GB less (85.74%) |
| Discourse Test Image | Commit Build | 10m 31s | 6m 55s | investigation only | 9.75 GB less (83.32%) |
| PostHog | Commit Build | 28m 14s | 14m 6s | 50% faster | n/a |
| Storybook | Commit Build | 3m 43s | 3m 28s | 7% faster | 1.42 GB less (52.29%) |
| OpenTelemetry Java | Commit Build | 2m 17s | 2m 29s | 9% slower | 851.63 MB less (42.96%) |
| Spring AI | Commit Build | 4m 23s | 2m 33s | 42% faster | 192.29 MB more (20.39%) |
| gRPC | Commit Build | 0m 55s | 1m 10s | 27% slower | 1.56 GB more (437.08%) |
| Zed | Commit Build | 21m 6s | 20m 38s | near tie | 8.78 GB more (78.58%) |
| Duckgres | Commit Build | 4m 21s | 3m 21s | 23% faster | n/a |
| Chroma | Commit Build | 18m 8s | 10m 55s | 40% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 4m 49s | 3m 43s | 23% faster | n/a |
| n8n | Commit Build | 3m 14s | 3m 33s | 10% slower | 1012.32 MB less (26.05%) |
| n8n Docker | Commit Build | 4m 15s | 3m 14s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 38s | 30% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 27s | 1m 22s | 44% faster | n/a |
