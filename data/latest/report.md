# Latest Benchmark Report

Generated: 2026-07-30 20:56 UTC

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
| Immich | Commit Build | 7m 47s | 3m 32s | 55% faster | 1.83 GB less (38.9%) |
| Mastodon | Commit Build | 2m 17s | 2m 19s | near tie | n/a |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 6s | near tie | n/a |
| Discourse | Commit Build | 3m 18s | 3m 3s | 8% faster | 8.62 GB less (89.3%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 8s | near tie | 8.95 GB less (92.73%) |
| Discourse Web-Only Image | Commit Build | 0m 12s | 0m 34s | 183% slower | 8.33 GB less (86.32%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 11s | near tie | 8.23 GB less (85.29%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 11s | near tie | 7.70 GB less (79.79%) |
| PostHog | Commit Build | 21m 45s | 14m 46s | 32% faster | n/a |
| Storybook | Commit Build | 3m 43s | 3m 33s | 4% faster | 1.39 GB less (51.71%) |
| OpenTelemetry Java | Commit Build | 2m 17s | 2m 29s | 9% slower | 851.63 MB less (42.96%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 0m 43s | 0m 53s | 23% slower | 1.51 GB more (482.48%) |
| Zed | Commit Build | 45m 37s | 44m 44s | near tie | 7.36 GB more (66.26%) |
| Duckgres | Commit Build | 4m 14s | 3m 24s | 20% faster | n/a |
| Chroma | Commit Build | 17m 51s | 11m 13s | 37% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 11m 1s | 7m 0s | 36% faster | n/a |
| n8n | Commit Build | 3m 9s | 3m 12s | near tie | 606.35 MB less (17.68%) |
| n8n Docker | Commit Build | 5m 19s | 3m 10s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 18s | 0m 40s | 49% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 42s | 1m 13s | 28% faster | n/a |
