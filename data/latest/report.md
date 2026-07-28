# Latest Benchmark Report

Generated: 2026-07-28 13:13 UTC

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
| Immich | Commit Build | 0m 11s | 0m 15s | near tie | 6.33 GB less (68.73%) |
| Mastodon | Commit Build | 2m 8s | 1m 41s | 21% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 24s | 0m 20s | near tie | n/a |
| Discourse | Commit Build | 3m 48s | 2m 39s | 30% faster | 8.86 GB less (89.56%) |
| Discourse Base Deps | Commit Build | 0m 13s | 0m 12s | near tie | 9.24 GB less (92.94%) |
| Discourse Web-Only Image | Commit Build | 0m 16s | 0m 15s | near tie | 8.62 GB less (86.71%) |
| Discourse Release Image | Commit Build | 0m 38s | 0m 12s | 68% faster | 8.52 GB less (85.71%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 10s | near tie | 8.29 GB less (80.95%) |
| PostHog | Commit Build | 25m 30s | 13m 18s | 48% faster | n/a |
| Storybook | Commit Build | 2m 58s | 3m 8s | 6% slower | 1.22 GB less (58.87%) |
| OpenTelemetry Java | Commit Build | 5m 52s | 5m 33s | 5% faster | 2.28 GB less (77.95%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 1m 45s | 0m 41s | 61% faster | 4.85 GB less (74.89%) |
| Zed | Commit Build | 40m 37s | 44m 46s | 10% slower | 619.12 MB less (12.98%) |
| Duckgres | Commit Build | 5m 3s | 3m 5s | 39% faster | n/a |
| Chroma | Commit Build | 22m 25s | 10m 56s | 51% faster | n/a |
| Linkerd2 Web | Commit Build | 3m 50s | 2m 10s | 43% faster | n/a |
| Qdrant | Commit Build | 11m 26s | 8m 54s | 22% faster | n/a |
| n8n | Commit Build | 4m 21s | 4m 4s | 7% faster | 2.33 GB less (46.49%) |
| n8n Docker | Commit Build | 6m 8s | 4m 15s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 3s | 0m 40s | 37% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 58s | 1m 10s | 41% faster | n/a |
