# Latest Benchmark Report

Generated: 2026-07-10 09:50 UTC

Coverage: 20 benchmarks; fresh 7/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo Go | Cold Build | 1m 25s | 1m 22s | 4% faster | 36.28 MB less (11.96%) |
| Storybook | Warm Build | 3m 41s | 0m 50s | 77% faster | 47.22 MB more (6.02%) |
| OpenTelemetry Java | Cold Build | 11m 29s | 10m 55s | 5% faster | 49.73 MB less (6.09%) |
| Spring AI | Warm Build | 0m 34s | 0m 27s | 21% faster | 176.12 MB less (17.96%) |
| gRPC | Cold Build | 25m 0s | 24m 40s | near tie | n/a |
| Zed | Warm Build | 20m 40s | 19m 17s | 7% faster | 2.13 GB less (78.15%) |
| n8n | Cold Build | 5m 27s | 5m 42s | 5% slower | 7.54 MB more (1.03%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 17s | 0m 7s | 59% faster | 1.59 GB less (82.4%) |
| Hugo Go | Commit Build | 0m 51s | 0m 49s | near tie | 1.21 GB less (81.28%) |
| Immich | Commit Build | 3m 36s | 3m 10s | 12% faster | 7.25 GB less (73.29%) |
| Mastodon | Commit Build | 2m 23s | 1m 59s | 17% faster | 8.93 GB less (89.61%) |
| Mastodon Streaming | Commit Build | 0m 11s | 0m 10s | near tie | 9.86 GB less (98.99%) |
| Discourse | Commit Build | 3m 15s | 3m 1s | 7% faster | 8.93 GB less (89.67%) |
| Discourse Base Deps | Commit Build | 0m 32s | 0m 18s | 44% faster | 10.42 GB less (93.69%) |
| Discourse Web-Only Image | Commit Build | 0m 20s | 0m 8s | 60% faster | 9.81 GB less (88.17%) |
| Discourse Release Image | Commit Build | 0m 8s | 0m 8s | near tie | 9.71 GB less (87.28%) |
| Discourse Test Image | Commit Build | 0m 8s | 0m 9s | near tie | 9.18 GB less (82.52%) |
| PostHog | Commit Build | 16m 25s | 11m 25s | 30% faster | 4.67 GB less (40.93%) |
| Storybook | Commit Build | 1m 33s | 0m 52s | 44% faster | 5.08 GB less (85.93%) |
| OpenTelemetry Java | Commit Build | 1m 16s | 1m 10s | 8% faster | 2.86 GB less (79.06%) |
| Spring AI | Commit Build | 1m 12s | 0m 57s | 21% faster | 3.22 GB less (70.34%) |
| gRPC | Commit Build | 8m 6s | 4m 45s | 41% faster | n/a |
| Zed | Commit Build | 26m 33s | 26m 2s | near tie | 10.57 GB less (92.3%) |
| n8n | Commit Build | 3m 3s | 2m 21s | 23% faster | 11.19 GB less (93.8%) |
| n8n Docker | Commit Build | 6m 2s | 4m 49s | investigation only | n/a |
| n8n Runners | Commit Build | 1m 5s | 0m 55s | 15% faster | n/a |
| n8n Runners Distroless | Commit Build | 3m 1s | 1m 34s | 48% faster | n/a |
