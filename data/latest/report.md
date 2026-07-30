# Latest Benchmark Report

Generated: 2026-07-30 09:31 UTC

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
| Zed | Warm Build | 20m 23s | 19m 53s | near tie | 7.02 MB less (0.25%) |
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
| Immich | Commit Build | 5m 53s | 3m 51s | 35% faster | 150.60 MB less (4.86%) |
| Mastodon | Commit Build | 3m 7s | 2m 28s | 21% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 13s | 0m 11s | near tie | n/a |
| Discourse | Commit Build | 4m 20s | 2m 37s | 40% faster | 8.80 GB less (89.5%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 9s | near tie | 10.58 GB less (93.78%) |
| Discourse Web-Only Image | Commit Build | 0m 16s | 0m 12s | near tie | 8.51 GB less (86.57%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 12s | near tie | 9.87 GB less (87.42%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 17s | near tie | 7.88 GB less (80.16%) |
| PostHog | Commit Build | 24m 58s | 14m 28s | 42% faster | n/a |
| Storybook | Commit Build | 1m 24s | 1m 36s | 14% slower | 885.54 MB less (50.26%) |
| OpenTelemetry Java | Commit Build | 9m 55s | 6m 48s | 31% faster | 650.84 MB less (37.15%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 0m 43s | 0m 55s | 28% slower | 1.53 GB more (544.76%) |
| Zed | Commit Build | 20m 41s | 23m 45s | 15% slower | 2.20 GB more (19.68%) |
| Duckgres | Commit Build | 4m 23s | 3m 11s | 27% faster | n/a |
| Chroma | Commit Build | 17m 51s | 11m 13s | 37% faster | n/a |
| Linkerd2 Web | Commit Build | 2m 20s | 1m 54s | 19% faster | n/a |
| Qdrant | Commit Build | 4m 26s | 3m 49s | 14% faster | n/a |
| n8n | Commit Build | 3m 7s | 3m 23s | 9% slower | 113.70 MB more (4.21%) |
| n8n Docker | Commit Build | 4m 46s | 2m 43s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 7s | 0m 37s | 45% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 47s | 1m 15s | 30% faster | n/a |
