# Latest Benchmark Report

Generated: 2026-09-02 09:41 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 9/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 28s | 0m 23s | near tie | n/a |
| Hugo Go | Cold Build | 1m 11s | 1m 29s | 25% slower | n/a |
| Immich | Cold Build | 4m 52s | 2m 52s | 41% faster | n/a |
| Mastodon | Warm Build | 1m 2s | 0m 14s | 77% faster | n/a |
| Mastodon Streaming | Cold Build | 0m 30s | 0m 23s | 23% faster | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Cold Build | 38m 29s | 16m 34s | 57% faster | n/a |
| Storybook | Warm Build | 4m 24s | 9m 2s | invalid sample | n/a |
| OpenTelemetry Java | Cold Build | 14m 6s | 11m 45s | 17% faster | n/a |
| Spring AI | Warm Build | 2m 32s | 1m 37s | 36% faster | n/a |
| gRPC | Warm Build | 1m 23s | 1m 52s | invalid sample | n/a |
| Duckgres | Cold Build | 6m 33s | 3m 37s | 45% faster | n/a |
| Chroma | Cold Build | 76m 49s | 83m 58s | 9% slower | n/a |
| Linkerd2 Web | Warm Build | 0m 13s | 0m 8s | near tie | n/a |
| Qdrant | Warm Build | 0m 24s | 0m 16s | 33% faster | n/a |
| n8n | Cold Build | 4m 5s | 4m 14s | 4% slower | n/a |
| n8n Docker | Warm Build | 6m 25s | 4m 47s | 25% faster | n/a |
| n8n Runners | Cold Build | 1m 28s | 1m 2s | 30% faster | n/a |
| n8n Runners Distroless | Cold Build | 2m 43s | 1m 8s | 58% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| Mastodon | Commit Build | 12m 48s | 8m 15s | investigation only | n/a |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| gRPC | Commit Build | 0m 45s | 1m 0s | 33% slower | 1.74 GB more (301.6%) |
| Duckgres | Commit Build | 5m 49s | 4m 20s | 26% faster | n/a |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
