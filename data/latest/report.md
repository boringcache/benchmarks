# Latest Benchmark Report

Generated: 2026-07-29 20:52 UTC

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
| Hugo | Commit Build | 3m 18s | 2m 52s | 13% faster | 80.31 MB less (18.77%) |
| Hugo Go | Commit Build | 0m 15s | 0m 19s | near tie | 339.68 MB less (55.99%) |
| Immich | Commit Build | 0m 15s | 0m 13s | near tie | 23.55 MB less (0.79%) |
| Mastodon | Commit Build | 2m 5s | 1m 35s | 24% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 8s | near tie | n/a |
| Discourse | Commit Build | 4m 21s | 2m 26s | 44% faster | 8.89 GB less (89.59%) |
| Discourse Base Deps | Commit Build | 0m 16s | 0m 16s | near tie | 9.22 GB less (92.92%) |
| Discourse Web-Only Image | Commit Build | 0m 16s | 0m 17s | near tie | 8.60 GB less (86.68%) |
| Discourse Release Image | Commit Build | 0m 10s | 0m 12s | near tie | 8.50 GB less (85.68%) |
| Discourse Test Image | Commit Build | 0m 14s | 0m 9s | near tie | 7.97 GB less (80.33%) |
| PostHog | Commit Build | 28m 37s | 14m 1s | 51% faster | n/a |
| Storybook | Commit Build | 1m 24s | 1m 36s | 14% slower | 885.54 MB less (50.26%) |
| OpenTelemetry Java | Commit Build | 9m 26s | 2m 45s | 71% faster | 142.85 MB more (17.91%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 0m 51s | 1m 4s | 25% slower | 1.53 GB more (545.83%) |
| Zed | Commit Build | 26m 49s | 29m 1s | 8% slower | 874.93 MB less (7.65%) |
| Duckgres | Commit Build | 4m 23s | 3m 11s | 27% faster | n/a |
| Chroma | Commit Build | 22m 8s | 13m 20s | 40% faster | n/a |
| Linkerd2 Web | Commit Build | 2m 20s | 1m 54s | 19% faster | n/a |
| Qdrant | Commit Build | 14m 0s | 3m 41s | 74% faster | n/a |
| n8n | Commit Build | 2m 20s | 2m 4s | 11% faster | 379.73 MB more (15.4%) |
| n8n Docker | Commit Build | 5m 6s | 2m 55s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 7s | 0m 47s | 30% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 9s | 1m 14s | 43% faster | n/a |
