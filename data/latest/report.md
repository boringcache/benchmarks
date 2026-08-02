# Latest Benchmark Report

Generated: 2026-08-02 16:57 UTC

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
| Zed | Warm Build | 20m 15s | 19m 50s | near tie | 352.34 MB more (12.56%) |
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
| Discourse | Commit Build | 5m 47s | 4m 38s | investigation only | 8.88 GB less (89.58%) |
| Discourse Base Deps | Commit Build | 0m 14s | 0m 7s | 50% faster | 9.21 GB less (92.91%) |
| Discourse Web-Only Image | Commit Build | 0m 20s | 0m 8s | 60% faster | 8.59 GB less (86.67%) |
| Discourse Release Image | Commit Build | 0m 12s | 0m 6s | 50% faster | 8.49 GB less (85.67%) |
| Discourse Test Image | Commit Build | 10m 4s | 6m 52s | investigation only | 7.96 GB less (80.33%) |
| PostHog | Commit Build | 36m 16s | 14m 11s | 61% faster | n/a |
| Storybook | Commit Build | 2m 10s | 2m 11s | near tie | 1.61 GB less (55.1%) |
| OpenTelemetry Java | Commit Build | 1m 17s | 1m 16s | near tie | 852.61 MB less (42.99%) |
| Spring AI | Commit Build | 4m 23s | 2m 33s | 42% faster | 192.29 MB more (20.39%) |
| gRPC | Commit Build | 0m 44s | 1m 46s | 141% slower | 1.71 GB more (363.56%) |
| Zed | Commit Build | 23m 5s | 23m 16s | near tie | 3.34 GB less (44.97%) |
| Duckgres | Commit Build | 4m 15s | 3m 21s | 21% faster | n/a |
| Chroma | Commit Build | 17m 14s | 10m 51s | 37% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 25s | 0m 10s | 60% faster | n/a |
| Qdrant | Commit Build | 4m 35s | 3m 35s | 22% faster | n/a |
| n8n | Commit Build | 2m 6s | 2m 14s | 6% slower | 1.74 GB less (38.6%) |
| n8n Docker | Commit Build | 4m 12s | 2m 45s | 35% faster | n/a |
| n8n Runners | Commit Build | 0m 55s | 0m 38s | 31% faster | n/a |
| n8n Runners Distroless | Commit Build | 2m 13s | 1m 21s | 39% faster | n/a |
