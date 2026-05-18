# Latest Benchmark Report

Generated: 2026-05-18 10:09 UTC

Coverage: 11 benchmarks; fresh 11/11, rolling 11/11.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 13s | 3m 31s | 9% slower | 7.22 GB less (95.6%) |
| Hugo Go | Cold Build | 1m 20s | 1m 6s | 18% faster | 706.12 MB more (240.01%) |
| Immich | Cold Build | 5m 20s | 4m 49s | 10% faster | 7.76 GB less (77.92%) |
| Mastodon | Cold Build | 9m 42s | 9m 42s | near tie | 9.82 GB less (90.45%) |
| PostHog | Warm Build | 2m 44s | 0m 18s | 89% faster | 3.47 GB less (35.02%) |
| Storybook | Cold Build | 3m 17s | 3m 32s | 8% slower | 44.76 MB more (6.13%) |
| OpenTelemetry Java | Cold Build | 11m 21s | 11m 19s | near tie | 51.58 MB less (6.11%) |
| Spring AI | Warm Build | 0m 44s | 0m 29s | 34% faster | 2.00 MB less (0.21%) |
| gRPC | Cold Build | 31m 53s | 28m 50s | 10% faster | 648.05 MB more (611.01%) |
| Zed | Cold Build | 49m 52s | 40m 18s | 19% faster | 6.92 MB less (0.24%) |
| n8n | Cold Build | 5m 10s | 5m 8s | near tie | 53.39 MB more (7.12%) |

## Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 56s | 2m 57s | near tie | 7.22 GB less (95.6%) |
| Hugo Go | Workflow Total | 1m 9s | 0m 41s | 41% faster | 425.76 MB less (18.43%) |
| Immich | Commit Build | 0m 13s | 0m 10s | near tie | 7.60 GB less (77.56%) |
| Mastodon | Commit Build | 2m 9s | 1m 58s | 9% faster | 8.95 GB less (89.76%) |
| PostHog | Workflow Total | 19m 6s | 13m 44s | 28% faster | 7.40 GB less (54.62%) |
| Storybook | Workflow Total | 3m 21s | 2m 54s | 13% faster | 1.12 GB less (59.64%) |
| OpenTelemetry Java | Workflow Total | 2m 13s | 1m 35s | 29% faster | 3.02 GB less (79.59%) |
| Spring AI | Workflow Total | 1m 7s | 0m 45s | 33% faster | 2.39 GB less (72.0%) |
| gRPC | Commit Build | 0m 42s | 0m 51s | 21% slower | 10.72 MB more (1.36%) |
| Zed | Workflow Total | 30m 25s | 29m 0s | 5% faster | 777.46 MB less (6.65%) |
| n8n | Commit Build | 4m 17s | 5m 49s | 36% slower | 3.13 GB less (75.61%) |
