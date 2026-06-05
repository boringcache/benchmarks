# Latest Benchmark Report

Generated: 2026-06-05 06:04 UTC

Coverage: 20 benchmarks; fresh 4/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Storybook | Cold Build | 3m 20s | 3m 37s | 9% slower | 44.78 MB more (6.13%) |
| OpenTelemetry Java | Warm Build | 1m 0s | 0m 54s | 10% faster | 52.36 MB less (5.85%) |
| Spring AI | Warm Build | 0m 35s | 0m 28s | 20% faster | 175.44 MB less (18.42%) |
| gRPC | Cold Build | 32m 26s | 22m 58s | 29% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 8s | 2m 51s | 9% faster | 2.99 GB less (89.9%) |
| Hugo Go | Commit Build | 0m 46s | 0m 48s | near tie | 1021.01 MB less (78.21%) |
| Immich | Commit Build | 3m 28s | 2m 49s | 19% faster | 7.30 GB less (77.72%) |
| Mastodon | Commit Build | 0m 17s | 0m 10s | 41% faster | 8.96 GB less (89.92%) |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 9s | near tie | 9.86 GB less (98.99%) |
| Discourse | Commit Build | 7m 3s | 5m 10s | investigation only | 8.91 GB less (89.73%) |
| Discourse Base Deps | Commit Build | 5m 45s | 3m 59s | investigation only | 9.29 GB less (93.51%) |
| Discourse Web-Only Image | Commit Build | 7m 20s | 6m 23s | investigation only | 8.69 GB less (87.54%) |
| Discourse Release Image | Commit Build | 8m 48s | 8m 27s | investigation only | 8.59 GB less (86.54%) |
| Discourse Test Image | Commit Build | 8m 22s | 7m 7s | investigation only | 8.02 GB less (80.72%) |
| PostHog | Commit Build | 18m 29s | 12m 26s | 33% faster | 3.69 GB less (37.99%) |
| Storybook | Commit Build | 3m 59s | 3m 48s | 5% faster | 2.41 GB less (74.98%) |
| OpenTelemetry Java | Commit Build | 7m 5s | 7m 18s | 3% slower | 2.36 GB less (72.71%) |
| Spring AI | Commit Build | 2m 43s | 3m 17s | 21% slower | 2.77 GB less (74.67%) |
| gRPC | Commit Build | 1m 27s | 1m 29s | near tie | n/a |
| Zed | Commit Build | 20m 20s | 19m 9s | 6% faster | 5.02 GB less (85.83%) |
| n8n | Commit Build | 2m 53s | 1m 51s | 36% faster | 11.91 GB less (93.84%) |
| n8n Docker | Commit Build | 5m 4s | 3m 47s | investigation only | n/a |
| n8n Runners | Commit Build | 0m 54s | 0m 47s | 13% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 53s | 1m 28s | 22% faster | n/a |
