# Latest Benchmark Report

Generated: 2026-07-29 17:06 UTC

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
| Immich | Commit Build | 0m 22s | 0m 16s | 27% faster | 23.52 MB less (0.79%) |
| Mastodon | Commit Build | 3m 5s | 1m 28s | 52% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 8s | near tie | n/a |
| Discourse | Commit Build | 3m 40s | 3m 2s | 17% faster | 8.72 GB less (89.41%) |
| Discourse Base Deps | Commit Build | 0m 11s | 0m 11s | near tie | 9.05 GB less (92.8%) |
| Discourse Web-Only Image | Commit Build | 0m 18s | 0m 22s | near tie | 8.43 GB less (86.45%) |
| Discourse Release Image | Commit Build | 0m 17s | 0m 10s | 41% faster | 8.33 GB less (85.43%) |
| Discourse Test Image | Commit Build | 0m 12s | 0m 21s | 75% slower | 7.80 GB less (79.99%) |
| PostHog | Commit Build | 25m 29s | 13m 17s | 48% faster | n/a |
| Storybook | Commit Build | 1m 24s | 1m 36s | 14% slower | 885.54 MB less (50.26%) |
| OpenTelemetry Java | Commit Build | 11m 0s | 5m 37s | 49% faster | 184.17 MB more (23.09%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 0m 41s | 0m 37s | near tie | 1.27 GB more (636.4%) |
| Zed | Commit Build | 42m 13s | 44m 3s | 4% slower | 974.16 MB less (8.52%) |
| Duckgres | Commit Build | 4m 23s | 3m 11s | 27% faster | n/a |
| Chroma | Commit Build | 22m 8s | 13m 20s | 40% faster | n/a |
| Linkerd2 Web | Commit Build | 2m 20s | 1m 54s | 19% faster | n/a |
| Qdrant | Commit Build | 14m 0s | 3m 41s | 74% faster | n/a |
| n8n | Commit Build | 1m 28s | 2m 22s | 61% slower | 496.10 MB more (21.43%) |
| n8n Docker | Commit Build | 4m 32s | 3m 6s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 41s | 24% faster | n/a |
| n8n Runners Distroless | Commit Build | 5m 43s | 1m 8s | 80% faster | n/a |
