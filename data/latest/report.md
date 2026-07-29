# Latest Benchmark Report

Generated: 2026-07-29 09:32 UTC

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
| Zed | Cold Build | 45m 51s | 55m 30s | 21% slower | 619.37 MB less (22.17%) |
| Duckgres | Warm Build | 0m 3s | 0m 2s | near tie | n/a |
| Chroma | Cold Build | 35m 33s | 16m 23s | 54% faster | n/a |
| Linkerd2 Web | Cold Build | 5m 18s | 3m 8s | 41% faster | n/a |
| Qdrant | Cold Build | 13m 5s | 10m 12s | 22% faster | n/a |
| n8n | Cold Build | 3m 48s | 3m 58s | 4% slower | 9.29 MB less (1.2%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 22s | 2m 51s | 15% faster | 7.40 GB less (95.61%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 11m 32s | 0m 8s | 99% faster | 281.42 MB more (10.55%) |
| Mastodon | Commit Build | 3m 6s | 1m 57s | 37% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 15s | 0m 10s | near tie | n/a |
| Discourse | Commit Build | 6m 53s | 4m 28s | investigation only | 5.32 GB less (83.74%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 17s | 89% slower | 5.64 GB less (88.93%) |
| Discourse Web-Only Image | Commit Build | 0m 11s | 0m 7s | near tie | 5.02 GB less (79.18%) |
| Discourse Release Image | Commit Build | 0m 22s | 0m 10s | 55% faster | 4.93 GB less (77.62%) |
| Discourse Test Image | Commit Build | 11m 23s | 6m 21s | investigation only | 5.95 GB less (75.3%) |
| PostHog | Commit Build | 23m 26s | 14m 9s | 40% faster | n/a |
| Storybook | Commit Build | 2m 54s | 3m 22s | 16% slower | 1.26 GB less (59.55%) |
| OpenTelemetry Java | Commit Build | 11m 0s | 5m 37s | 49% faster | 184.17 MB more (23.09%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 0m 41s | 0m 37s | near tie | 1.27 GB more (636.4%) |
| Zed | Commit Build | 45m 37s | 48m 46s | 7% slower | 410.50 MB more (6.4%) |
| Duckgres | Commit Build | 4m 46s | 3m 22s | 29% faster | n/a |
| Chroma | Commit Build | 22m 8s | 13m 20s | 40% faster | n/a |
| Linkerd2 Web | Commit Build | 2m 20s | 1m 54s | 19% faster | n/a |
| Qdrant | Commit Build | 13m 46s | 3m 37s | 74% faster | n/a |
| n8n | Commit Build | 3m 13s | 2m 59s | 7% faster | 1.00 GB more (54.96%) |
| n8n Docker | Commit Build | 5m 12s | 3m 41s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 0s | 0m 41s | 32% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 14s | 1m 16s | 43% faster | n/a |
