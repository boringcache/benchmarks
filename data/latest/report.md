# Latest Benchmark Report

Generated: 2026-08-29 05:51 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 11/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 30s | 0m 22s | 27% faster | n/a |
| Hugo Go | Cold Build | 1m 11s | 1m 29s | 25% slower | n/a |
| Immich | Cold Build | 6m 0s | 2m 56s | 51% faster | n/a |
| Mastodon | Cold Build | 11m 43s | 8m 23s | 28% faster | n/a |
| Mastodon Streaming | Cold Build | 0m 48s | 0m 19s | 60% faster | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Cold Build | 36m 12s | 16m 19s | 55% faster | n/a |
| Storybook | Warm Build | 5m 33s | 4m 44s | invalid sample | n/a |
| OpenTelemetry Java | Cold Build | 14m 6s | 11m 45s | 17% faster | n/a |
| Spring AI | Warm Build | 2m 32s | 1m 37s | 36% faster | n/a |
| gRPC | Warm Build | 1m 23s | 1m 52s | invalid sample | n/a |
| Duckgres | Warm Build | 0m 17s | 0m 8s | 53% faster | n/a |
| Chroma | Warm Build | 0m 11s | 0m 8s | near tie | n/a |
| Linkerd2 Web | Cold Build | 4m 31s | 3m 19s | 27% faster | n/a |
| Qdrant | Cold Build | 13m 51s | 9m 43s | 30% faster | n/a |
| n8n | Warm Build | 1m 28s | 1m 0s | 32% faster | n/a |
| n8n Docker | Cold Build | 8m 10s | 5m 21s | 34% faster | n/a |
| n8n Runners | Warm Build | 1m 40s | 0m 53s | 47% faster | n/a |
| n8n Runners Distroless | Cold Build | 2m 50s | 1m 26s | 49% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 0s | 2m 47s | 7% faster | 792.74 MB less (69.52%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| Mastodon | Commit Build | 12m 48s | 8m 15s | investigation only | n/a |
| Storybook | Commit Build | 3m 16s | 3m 52s | 18% slower | 1.86 GB less (57.94%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| gRPC | Commit Build | 0m 45s | 1m 0s | 33% slower | 1.74 GB more (301.6%) |
| Duckgres | Commit Build | 5m 49s | 4m 20s | 26% faster | n/a |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
| Qdrant | Commit Build | 5m 31s | 4m 8s | 25% faster | n/a |
