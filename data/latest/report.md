# Latest Benchmark Report

Generated: 2026-07-31 20:54 UTC

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
| Zed | Warm Build | 21m 39s | 20m 51s | 4% faster | 7.30 MB less (0.26%) |
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
| Discourse | Commit Build | 3m 17s | 2m 38s | 20% faster | 9.31 GB less (90.01%) |
| Discourse Base Deps | Commit Build | 0m 15s | 0m 10s | near tie | 9.64 GB less (93.21%) |
| Discourse Web-Only Image | Commit Build | 0m 16s | 0m 9s | 44% faster | 9.02 GB less (87.23%) |
| Discourse Release Image | Commit Build | 0m 14s | 0m 24s | 71% slower | 8.92 GB less (86.27%) |
| Discourse Test Image | Commit Build | 0m 41s | 0m 10s | 76% faster | 8.39 GB less (81.14%) |
| PostHog | Commit Build | 21m 28s | 14m 7s | 34% faster | n/a |
| Storybook | Commit Build | 3m 29s | 3m 16s | 6% faster | 1.55 GB less (54.14%) |
| OpenTelemetry Java | Commit Build | 1m 17s | 1m 16s | near tie | 852.61 MB less (42.99%) |
| Spring AI | Commit Build | 4m 23s | 2m 33s | 42% faster | 192.29 MB more (20.39%) |
| gRPC | Commit Build | 18m 33s | 14m 21s | 23% faster | 1.65 GB more (389.6%) |
| Zed | Commit Build | 23m 24s | 26m 43s | 14% slower | 2.34 GB less (41.87%) |
| Duckgres | Commit Build | 4m 59s | 3m 55s | 21% faster | n/a |
| Chroma | Commit Build | 19m 12s | 11m 13s | 42% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 4m 46s | 3m 43s | 22% faster | n/a |
| n8n | Commit Build | 2m 29s | 2m 25s | near tie | 1.62 GB less (36.24%) |
| n8n Docker | Commit Build | 4m 24s | 3m 7s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 34s | 37% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 22s | 1m 8s | 52% faster | n/a |
