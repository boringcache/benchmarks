# Latest Benchmark Report

Generated: 2026-05-19 17:33 UTC

Coverage: 12 benchmarks; fresh 12/12, rolling 12/12.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 13s | 3m 31s | 9% slower | 7.22 GB less (95.6%) |
| Hugo Go | Cold Build | 1m 20s | 1m 6s | 18% faster | 706.12 MB more (240.01%) |
| Immich | Warm Build | 0m 14s | 0m 9s | near tie | 8.13 GB less (78.6%) |
| Mastodon | Cold Build | 10m 51s | 9m 17s | 14% faster | 9.55 GB less (90.21%) |
| Discourse | Cold Build | 5m 49s | 5m 3s | 13% faster | 1.03 GB more (19028.12%) |
| PostHog | Warm Build | 2m 44s | 0m 18s | 89% faster | 3.47 GB less (35.02%) |
| Storybook | Cold Build | 3m 17s | 3m 32s | 8% slower | 44.76 MB more (6.13%) |
| OpenTelemetry Java | Cold Build | 11m 21s | 11m 19s | near tie | 51.58 MB less (6.11%) |
| Spring AI | Warm Build | 0m 44s | 0m 29s | 34% faster | 2.00 MB less (0.21%) |
| gRPC | Cold Build | 32m 31s | 37m 38s | 16% slower | 648.05 MB more (611.03%) |
| Zed | Workflow Total | 56m 3s | 51m 13s | 9% faster | 2.05 GB less (73.57%) |
| n8n | Cold Build | 5m 10s | 5m 8s | near tie | 53.39 MB more (7.12%) |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 19s | 2m 57s | 11% faster | 6.70 GB less (95.27%) |
| Hugo Go | Workflow Total | 0m 56s | 0m 41s | 27% faster | 692.70 MB more (41.31%) |
| Immich | Commit Build | 0m 27s | 0m 13s | 52% faster | 7.34 GB less (76.83%) |
| Mastodon | Commit Build | 2m 18s | 1m 56s | 16% faster | 9.04 GB less (89.73%) |
| Discourse | Commit Build | 3m 47s | 3m 1s | 20% faster | 5.88 GB less (84.98%) |
| PostHog | Commit Build | 15m 15s | 11m 49s | 23% faster | 3.28 GB less (34.69%) |
| Storybook | Workflow Total | 1m 41s | 1m 31s | 10% faster | 1.24 GB less (61.99%) |
| OpenTelemetry Java | Workflow Total | 7m 0s | 6m 2s | 14% faster | 2.98 GB less (79.4%) |
| Spring AI | Workflow Total | 1m 27s | 0m 48s | 45% faster | 2.21 GB less (66.73%) |
| gRPC | Commit Build | 1m 3s | 23m 42s | 2157% slower | 930.52 MB more (79.26%) |
| Zed | Workflow Total | 45m 27s | 41m 6s | 10% faster | 2.71 GB less (23.63%) |
| n8n | Commit Build | 4m 29s | 4m 27s | near tie | 3.72 GB less (71.2%) |
