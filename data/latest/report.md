# Latest Benchmark Report

Generated: 2026-07-29 01:06 UTC

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
| Immich | Commit Build | 7m 44s | 0m 10s | 98% faster | 2.88 GB more (14977029.14%) |
| Mastodon | Commit Build | 3m 6s | 1m 57s | 37% faster | n/a |
| Mastodon Streaming | Commit Build | 0m 15s | 0m 10s | near tie | n/a |
| Discourse | Commit Build | 4m 9s | 2m 33s | 39% faster | 4.96 GB less (82.78%) |
| Discourse Base Deps | Commit Build | 0m 11s | 0m 11s | near tie | 5.29 GB less (88.29%) |
| Discourse Web-Only Image | Commit Build | 0m 25s | 0m 9s | 64% faster | 4.68 GB less (77.97%) |
| Discourse Release Image | Commit Build | 0m 22s | 0m 8s | 64% faster | 4.58 GB less (76.31%) |
| Discourse Test Image | Commit Build | 0m 9s | 0m 18s | 100% slower | 4.05 GB less (67.47%) |
| PostHog | Commit Build | 0m 26s | 0m 22s | near tie | n/a |
| Storybook | Commit Build | 2m 54s | 3m 22s | 16% slower | 1.26 GB less (59.55%) |
| OpenTelemetry Java | Commit Build | 11m 0s | 5m 37s | 49% faster | 184.17 MB more (23.09%) |
| Spring AI | Commit Build | 0m 49s | 0m 46s | near tie | 1.23 GB less (57.03%) |
| gRPC | Commit Build | 0m 41s | 0m 37s | near tie | 1.27 GB more (636.4%) |
| Zed | Commit Build | 56m 4s | 24m 26s | 56% faster | 3.13 GB more (114.69%) |
| Duckgres | Commit Build | 4m 46s | 3m 22s | 29% faster | n/a |
| Chroma | Commit Build | 22m 25s | 10m 56s | 51% faster | n/a |
| Linkerd2 Web | Commit Build | 2m 20s | 1m 54s | 19% faster | n/a |
| Qdrant | Commit Build | 13m 46s | 3m 37s | 74% faster | n/a |
| n8n | Commit Build | 3m 17s | 3m 35s | 9% slower | 1.22 GB more (78.13%) |
| n8n Docker | Commit Build | 5m 41s | 3m 38s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 13s | 0m 37s | 49% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 44s | 1m 16s | 27% faster | n/a |
