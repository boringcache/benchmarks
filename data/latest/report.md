# Latest Benchmark Report

Generated: 2026-08-01 05:45 UTC

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
| Zed | Warm Build | 20m 44s | 20m 14s | near tie | 8.10 MB less (0.29%) |
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
| Immich | Commit Build | 0m 15s | 0m 9s | 40% faster | 7.11 GB less (71.18%) |
| Mastodon | Commit Build | 2m 47s | 1m 35s | 43% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 13s | near tie | n/a |
| Discourse | Commit Build | 3m 13s | 2m 31s | 22% faster | 8.87 GB less (89.58%) |
| Discourse Base Deps | Commit Build | 0m 17s | 0m 10s | 41% faster | 9.20 GB less (92.91%) |
| Discourse Web-Only Image | Commit Build | 0m 17s | 0m 10s | 41% faster | 8.59 GB less (86.66%) |
| Discourse Release Image | Commit Build | 0m 14s | 0m 10s | near tie | 8.49 GB less (85.66%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 7s | 50% faster | 7.96 GB less (80.31%) |
| PostHog | Commit Build | 23m 42s | 14m 27s | 39% faster | n/a |
| Storybook | Commit Build | 2m 10s | 2m 11s | near tie | 1.61 GB less (55.1%) |
| OpenTelemetry Java | Commit Build | 1m 17s | 1m 16s | near tie | 852.61 MB less (42.99%) |
| Spring AI | Commit Build | 4m 23s | 2m 33s | 42% faster | 192.29 MB more (20.39%) |
| gRPC | Commit Build | 0m 44s | 1m 46s | 141% slower | 1.71 GB more (363.56%) |
| Zed | Commit Build | 46m 45s | 45m 12s | 3% faster | 7.17 GB less (64.15%) |
| Duckgres | Commit Build | 4m 15s | 3m 21s | 21% faster | n/a |
| Chroma | Commit Build | 17m 14s | 10m 51s | 37% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 5m 30s | 4m 16s | 22% faster | n/a |
| n8n | Commit Build | 1m 8s | 1m 9s | near tie | 1.64 GB less (36.52%) |
| n8n Docker | Commit Build | 5m 38s | 2m 53s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 53s | 0m 38s | 28% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 55s | 1m 18s | 32% faster | n/a |
