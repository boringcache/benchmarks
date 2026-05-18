# Latest Benchmark Report

Generated: 2026-05-18 13:51 UTC

Coverage: 12 benchmarks; fresh 12/12, rolling 12/12.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 13s | 3m 31s | 9% slower | 7.22 GB less (95.6%) |
| Hugo Go | Cold Build | 1m 20s | 1m 6s | 18% faster | 706.12 MB more (240.01%) |
| Immich | Cold Build | 5m 20s | 4m 49s | 10% faster | 7.76 GB less (77.92%) |
| Mastodon | Cold Build | 9m 42s | 9m 42s | near tie | 9.82 GB less (90.45%) |
| Discourse | Cold Build | 5m 49s | 5m 3s | 13% faster | 1.03 GB more (19028.12%) |
| PostHog | Warm Build | 2m 44s | 0m 18s | 89% faster | 3.47 GB less (35.02%) |
| Storybook | Cold Build | 3m 17s | 3m 32s | 8% slower | 44.76 MB more (6.13%) |
| OpenTelemetry Java | Cold Build | 11m 21s | 11m 19s | near tie | 51.58 MB less (6.11%) |
| Spring AI | Warm Build | 0m 44s | 0m 29s | 34% faster | 2.00 MB less (0.21%) |
| gRPC | Cold Build | 31m 53s | 28m 50s | 10% faster | 648.05 MB more (611.01%) |
| Zed | Workflow Total | 56m 3s | 51m 13s | 9% faster | 2.05 GB less (73.57%) |
| n8n | Cold Build | 5m 10s | 5m 8s | near tie | 53.39 MB more (7.12%) |

## Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 56s | 2m 57s | near tie | 7.22 GB less (95.6%) |
| Hugo Go | Workflow Total | 1m 9s | 0m 41s | 41% faster | 425.76 MB less (18.43%) |
| Immich | Commit Build | 0m 13s | 0m 10s | near tie | 7.60 GB less (77.56%) |
| Mastodon | Commit Build | 4m 17s | 1m 55s | 55% faster | 8.96 GB less (89.63%) |
| Discourse | Commit Build | 0m 16s | 0m 13s | near tie | 180.95 MB less (14.53%) |
| PostHog | Commit Build | 20m 42s | 15m 15s | 26% faster | 3.14 GB less (32.74%) |
| Storybook | Workflow Total | 3m 21s | 2m 54s | 13% faster | 1.12 GB less (59.64%) |
| OpenTelemetry Java | Workflow Total | 3m 50s | 1m 20s | 65% faster | 2.90 GB less (78.94%) |
| Spring AI | Workflow Total | 1m 53s | 1m 31s | 19% faster | 2.39 GB less (71.92%) |
| gRPC | Commit Build | 0m 42s | 0m 51s | 21% slower | 10.72 MB more (1.36%) |
| Zed | Workflow Total | 25m 50s | 23m 1s | 11% faster | 8.58 GB less (75.2%) |
| n8n | Commit Build | 5m 21s | 6m 28s | 21% slower | 3.21 GB less (74.7%) |
