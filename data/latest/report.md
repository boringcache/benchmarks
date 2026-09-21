# Latest Benchmark Report

Generated: 2026-09-21 09:47 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 8/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 22s | 0m 18s | near tie | n/a |
| Hugo Go | Cold Build | 1m 10s | 1m 18s | 11% slower | n/a |
| Immich | Warm Build | 0m 23s | 0m 12s | 48% faster | n/a |
| Mastodon | Warm Build | 0m 37s | 0m 18s | 51% faster | n/a |
| Mastodon Streaming | Cold Build | 0m 33s | 0m 17s | 48% faster | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Cold Build | 27m 48s | 17m 13s | 38% faster | n/a |
| Storybook | Warm Build | 4m 35s | 4m 39s | invalid sample | n/a |
| OpenTelemetry Java | Warm Build | 2m 45s | 14m 56s | invalid sample | n/a |
| Spring AI | Warm Build | 2m 23s | 1m 43s | 28% faster | n/a |
| gRPC | Warm Build | 1m 22s | 1m 57s | invalid sample | n/a |
| Duckgres | Cold Build | 6m 41s | 3m 29s | 48% faster | n/a |
| Chroma | Warm Build | 63m 56s | 5m 24s | 92% faster | n/a |
| Linkerd2 Web | Cold Build | 4m 36s | 2m 40s | 42% faster | n/a |
| Qdrant | Warm Build | 0m 29s | 0m 14s | 52% faster | n/a |
| n8n | Cold Build | 2m 46s | 2m 31s | 9% faster | n/a |
| n8n Docker | Warm Build | 2m 24s | 1m 17s | 47% faster | n/a |
| n8n Runners | Cold Build | 1m 55s | 0m 45s | 61% faster | n/a |
| n8n Runners Distroless | Warm Build | 2m 34s | 1m 8s | 56% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| gRPC | Commit Build | 2m 21s | 0m 40s | 72% faster | n/a |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
| n8n | Commit Build | 4m 11s | 3m 31s | 16% faster | 1.96 GB less (41.64%) |
