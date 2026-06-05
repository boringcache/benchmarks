# Latest Benchmark Report

Generated: 2026-06-05 13:35 UTC

Coverage: 20 benchmarks; fresh 5/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 20s | 3m 37s | 9% slower | 44.78 MB more (6.13%) |
| OpenTelemetry Java | Warm Build | 1m 0s | 0m 54s | 10% faster | 52.36 MB less (5.85%) |
| Spring AI | Warm Build | 0m 35s | 0m 28s | 20% faster | 175.44 MB less (18.42%) |
| gRPC | Cold Build | 32m 26s | 22m 58s | 29% faster | n/a |
| Zed | Cold Build | 51m 38s | 51m 26s | near tie | 2.09 GB less (75.51%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 8s | 2m 51s | 9% faster | 2.99 GB less (89.9%) |
| Hugo Go | Commit Build | 0m 46s | 0m 48s | near tie | 1021.01 MB less (78.21%) |
| Immich | Commit Build | 3m 28s | 2m 49s | 19% faster | 7.30 GB less (77.72%) |
| Mastodon | Commit Build | 3m 50s | 2m 46s | 28% faster | 8.94 GB less (89.91%) |
| Mastodon Streaming | Commit Build | 0m 7s | 0m 13s | 86% slower | 9.84 GB less (98.99%) |
| Discourse | Commit Build | 3m 50s | 2m 58s | 23% faster | 8.97 GB less (89.78%) |
| Discourse Base Deps | Commit Build | 0m 9s | 0m 7s | near tie | 9.34 GB less (93.54%) |
| Discourse Web-Only Image | Commit Build | 0m 12s | 0m 9s | near tie | 8.75 GB less (87.61%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 10s | 38% faster | 8.65 GB less (86.62%) |
| Discourse Test Image | Commit Build | 0m 13s | 0m 8s | near tie | 8.07 GB less (80.83%) |
| PostHog | Commit Build | 17m 5s | 11m 8s | 35% faster | 3.86 GB less (39.05%) |
| Storybook | Commit Build | 1m 33s | 1m 14s | 20% faster | 2.37 GB less (74.66%) |
| OpenTelemetry Java | Commit Build | 7m 5s | 7m 18s | 3% slower | 2.36 GB less (72.71%) |
| Spring AI | Commit Build | 2m 40s | 2m 40s | near tie | 2.77 GB less (74.66%) |
| gRPC | Commit Build | 19m 53s | 13m 11s | 34% faster | n/a |
| Zed | Commit Build | 31m 11s | 25m 32s | 18% faster | 7.89 GB less (90.5%) |
| n8n | Commit Build | 3m 38s | 2m 24s | 34% faster | 12.15 GB less (93.95%) |
| n8n Docker | Commit Build | 4m 53s | 4m 44s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 59s | 0m 42s | 29% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 52s | 1m 20s | 29% faster | n/a |
