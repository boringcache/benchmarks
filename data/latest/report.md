# Latest Benchmark Report

Generated: 2026-07-31 01:09 UTC

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
| Mastodon | Commit Build | 2m 17s | 2m 19s | near tie | n/a |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 6s | near tie | n/a |
| Discourse | Commit Build | 4m 9s | 3m 3s | 27% faster | 8.70 GB less (89.39%) |
| Discourse Base Deps | Commit Build | 0m 14s | 0m 6s | 57% faster | 9.03 GB less (92.79%) |
| Discourse Web-Only Image | Commit Build | 0m 10s | 0m 7s | near tie | 8.42 GB less (86.43%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 10s | 38% faster | 8.32 GB less (85.41%) |
| Discourse Test Image | Commit Build | 0m 19s | 0m 9s | 53% faster | 7.79 GB less (79.96%) |
| PostHog | Commit Build | 24m 8s | 14m 40s | 39% faster | n/a |
| Storybook | Commit Build | 3m 43s | 3m 33s | 4% faster | 1.39 GB less (51.71%) |
| OpenTelemetry Java | Commit Build | 2m 17s | 2m 29s | 9% slower | 851.63 MB less (42.96%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 0m 45s | 1m 6s | 47% slower | 1.59 GB more (485.62%) |
| Zed | Commit Build | 24m 59s | 23m 13s | 7% faster | 7.96 GB more (71.2%) |
| Duckgres | Commit Build | 4m 14s | 3m 24s | 20% faster | n/a |
| Chroma | Commit Build | 18m 8s | 10m 55s | 40% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 11m 14s | 8m 42s | 23% faster | n/a |
| n8n | Commit Build | 2m 58s | 2m 54s | near tie | 777.53 MB less (21.45%) |
| n8n Docker | Commit Build | 4m 38s | 3m 15s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 0s | 0m 47s | 22% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 59s | 1m 16s | 36% faster | n/a |
