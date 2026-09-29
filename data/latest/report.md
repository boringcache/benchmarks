# Latest Benchmark Report

Generated: 2026-09-29 14:11 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 11/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 27s | 0m 20s | 26% faster | n/a |
| Hugo Go | Cold Build | 1m 11s | 1m 16s | 7% slower | 619.00 MB more (401.19%) |
| Immich | Warm Build | 0m 20s | 0m 10s | 50% faster | n/a |
| Mastodon | Cold Build | 10m 29s | 6m 45s | 36% faster | n/a |
| Mastodon Streaming | Warm Build | 0m 16s | 0m 10s | 38% faster | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Warm Build | 0m 42s | 0m 18s | 57% faster | n/a |
| Storybook | Cold Build | 3m 46s | 6m 11s | 64% slower | n/a |
| OpenTelemetry Java | Cold Build | 12m 14s | 15m 43s | 28% slower | 582.82 KB more (1.18%) |
| Spring AI | Cold Build | 5m 47s | 8m 8s | 41% slower | 20.21 MB more (11.18%) |
| gRPC | Cold Build | 30m 47s | 21m 53s | 29% faster | n/a |
| Duckgres | Cold Build | 7m 28s | 4m 10s | 44% faster | n/a |
| Chroma | Warm Build | 80m 19s | 2m 26s | 97% faster | n/a |
| Linkerd2 Web | Cold Build | 4m 53s | 3m 15s | 33% faster | n/a |
| Qdrant | Warm Build | 0m 29s | 0m 18s | 38% faster | n/a |
| n8n | Cold Build | 2m 33s | 2m 36s | near tie | 1.28 MB less (2.55%) |
| n8n Docker | Warm Build | 1m 59s | 0m 57s | 52% faster | n/a |
| n8n Runners | Cold Build | 1m 30s | 0m 43s | 52% faster | n/a |
| n8n Runners Distroless | Warm Build | 2m 23s | 1m 8s | 52% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| Mastodon | Commit Build | 12m 48s | 8m 15s | investigation only | n/a |
| Storybook | Commit Build | 3m 58s | 3m 25s | 14% faster | 1.81 GB less (57.58%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 1m 29s | 1m 23s | 7% faster | 3.23 GB less (70.48%) |
| gRPC | Commit Build | 0m 45s | 1m 0s | 33% slower | 1.74 GB more (301.6%) |
| Duckgres | Commit Build | 5m 49s | 4m 20s | 26% faster | n/a |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
| n8n | Commit Build | 4m 11s | 3m 31s | 16% faster | 1.96 GB less (41.64%) |
