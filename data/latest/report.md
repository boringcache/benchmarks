# Latest Benchmark Report

Generated: 2026-07-29 13:14 UTC

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
| Hugo | Commit Build | 3m 32s | 2m 16s | 36% faster | 347.58 MB more (131576858.84%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 11m 32s | 0m 8s | 99% faster | 281.42 MB more (10.55%) |
| Mastodon | Commit Build | 2m 46s | 1m 33s | 44% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 7s | near tie | n/a |
| Discourse | Commit Build | 4m 13s | 2m 43s | 36% faster | 8.37 GB less (89.01%) |
| Discourse Base Deps | Commit Build | 0m 10s | 0m 9s | near tie | 8.70 GB less (92.53%) |
| Discourse Web-Only Image | Commit Build | 0m 14s | 0m 13s | near tie | 8.08 GB less (85.95%) |
| Discourse Release Image | Commit Build | 0m 9s | 0m 10s | near tie | 7.98 GB less (84.89%) |
| Discourse Test Image | Commit Build | 0m 15s | 0m 8s | 47% faster | 7.45 GB less (79.25%) |
| PostHog | Commit Build | 20m 47s | 17m 52s | 14% faster | n/a |
| Storybook | Commit Build | 3m 17s | 1m 1s | 69% faster | 853.79 KB less (0.1%) |
| OpenTelemetry Java | Commit Build | 11m 0s | 5m 37s | 49% faster | 184.17 MB more (23.09%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 0m 41s | 0m 37s | near tie | 1.27 GB more (636.4%) |
| Zed | Commit Build | 36m 57s | 47m 38s | 29% slower | 1.02 GB less (11.18%) |
| Duckgres | Commit Build | 4m 46s | 3m 22s | 29% faster | n/a |
| Chroma | Commit Build | 22m 8s | 13m 20s | 40% faster | n/a |
| Linkerd2 Web | Commit Build | 2m 20s | 1m 54s | 19% faster | n/a |
| Qdrant | Commit Build | 14m 0s | 3m 41s | 74% faster | n/a |
| n8n | Commit Build | 3m 18s | 3m 23s | near tie | 711.85 MB more (32.58%) |
| n8n Docker | Commit Build | 4m 55s | 2m 54s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 59s | 0m 39s | 34% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 46s | 1m 10s | 34% faster | n/a |
