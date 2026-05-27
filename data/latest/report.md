# Latest Benchmark Report

Generated: 2026-05-27 13:13 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 20/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 22s | 3m 30s | 4% slower | 2.04 GB less (86.0%) |
| Hugo Go | Cold Build | 1m 20s | 1m 23s | 4% slower | 42.35 MB less (14.3%) |
| Immich | Warm Build | 0m 10s | 0m 7s | near tie | 8.34 GB less (80.1%) |
| Mastodon | Cold Build | 9m 35s | 9m 5s | 5% faster | 8.98 GB less (89.8%) |
| Mastodon Streaming | Cold Build | 0m 21s | 0m 42s | 100% slower | 9.89 GB less (98.99%) |
| Discourse | Cold Build | 5m 50s | 5m 4s | 13% faster | 8.97 GB less (89.75%) |
| Discourse Base Deps | Warm Build | 0m 11s | 0m 8s | near tie | 9.31 GB less (93.35%) |
| Discourse Web-Only Image | Warm Build | 0m 11s | 0m 10s | near tie | 8.71 GB less (87.3%) |
| Discourse Release Image | Cold Build | 8m 46s | 7m 29s | 15% faster | 8.63 GB less (86.46%) |
| Discourse Test Image | Cold Build | 8m 57s | 7m 45s | 13% faster | 8.05 GB less (80.68%) |
| PostHog | Cold Build | 21m 58s | 15m 41s | 29% faster | 6.80 GB less (51.43%) |
| Storybook | Cold Build | 3m 51s | 3m 33s | 8% faster | 43.94 MB more (6.01%) |
| OpenTelemetry Java | Cold Build | 11m 21s | 10m 59s | 3% faster | 52.70 MB less (5.89%) |
| Spring AI | Cold Build | 3m 51s | 3m 58s | 3% slower | 177.45 MB less (18.84%) |
| gRPC | Cold Build | 28m 23s | 24m 34s | 13% faster | n/a |
| Zed | Cold Build | 50m 4s | 50m 39s | near tie | 2.05 GB less (73.62%) |
| n8n | Cold Build | 5m 21s | 5m 8s | 4% faster | 14.91 MB more (2.0%) |
| n8n Docker | Warm Build | 2m 6s | 2m 2s | 3% faster | n/a |
| n8n Runners | Cold Build | 1m 2s | 1m 3s | near tie | n/a |
| n8n Runners Distroless | Warm Build | 1m 2s | 0m 57s | 8% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 13s | 2m 58s | 8% faster | 2.05 GB less (85.92%) |
| Hugo Go | Commit Build | 0m 57s | 0m 56s | near tie | 1.49 GB less (84.32%) |
| Immich | Commit Build | 4m 47s | 3m 7s | 35% faster | 7.92 GB less (79.22%) |
| Mastodon | Commit Build | 3m 54s | 2m 47s | 29% faster | 8.92 GB less (89.74%) |
| Mastodon Streaming | Commit Build | 0m 8s | 0m 8s | near tie | 9.83 GB less (98.99%) |
| Discourse | Commit Build | 3m 33s | 2m 57s | 17% faster | 8.96 GB less (89.73%) |
| Discourse Base Deps | Commit Build | 0m 13s | 0m 9s | near tie | 9.32 GB less (93.36%) |
| Discourse Web-Only Image | Commit Build | 0m 18s | 0m 9s | 50% faster | 8.72 GB less (87.31%) |
| Discourse Release Image | Commit Build | 0m 16s | 0m 9s | 44% faster | 8.64 GB less (86.48%) |
| Discourse Test Image | Commit Build | 0m 13s | 0m 9s | near tie | 8.06 GB less (80.7%) |
| PostHog | Commit Build | 16m 30s | 12m 20s | 25% faster | 3.75 GB less (37.88%) |
| Storybook | Commit Build | 0m 51s | 0m 51s | near tie | 1.77 GB less (69.28%) |
| OpenTelemetry Java | Commit Build | 5m 21s | 4m 44s | 12% faster | 3.12 GB less (77.86%) |
| Spring AI | Commit Build | 1m 34s | 1m 18s | 17% faster | 2.70 GB less (75.53%) |
| gRPC | Commit Build | 1m 0s | 0m 51s | 15% faster | n/a |
| Zed | Commit Build | 18m 25s | 18m 15s | near tie | 10.73 GB less (93.53%) |
| n8n | Commit Build | 4m 19s | 5m 37s | 30% slower | 7.46 GB less (90.68%) |
| n8n Docker | Commit Build | 3m 52s | 3m 13s | 17% faster | n/a |
| n8n Runners | Commit Build | 1m 0s | 0m 48s | 20% faster | n/a |
| n8n Runners Distroless | Commit Build | 1m 34s | 1m 26s | 9% faster | n/a |
