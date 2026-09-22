# Latest Benchmark Report

Generated: 2026-09-22 18:15 UTC

Coverage: 20 benchmarks; fresh 20/20, rolling 7/20.

Rows are latest complete same-commit pairs.

## Fresh

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 4m 14s | 3m 42s | 13% faster | n/a |
| Hugo Go | Cold Build | 1m 13s | 1m 16s | 4% slower | 619.11 MB more (401.59%) |
| Immich | Cold Build | 5m 38s | 3m 1s | 46% faster | n/a |
| Mastodon | Warm Build | 0m 10s | 0m 9s | near tie | n/a |
| Mastodon Streaming | Cold Build | 0m 23s | 0m 23s | near tie | n/a |
| Discourse Image Factory (amd64) | Cold Build | 43m 9s | 41m 46s | 3% faster | n/a |
| Discourse Image Factory (arm64) | Cold Build | 38m 58s | 47m 1s | 21% slower | n/a |
| PostHog | Cold Build | 27m 48s | 17m 13s | 38% faster | n/a |
| Storybook | Warm Build | 4m 26s | 4m 56s | invalid sample | n/a |
| OpenTelemetry Java | Warm Build | 2m 45s | 14m 56s | invalid sample | n/a |
| Spring AI | Cold Build | 8m 58s | 7m 50s | 13% faster | 20.44 MB more (11.32%) |
| gRPC | Warm Build | 1m 38s | 1m 45s | invalid sample | 548.71 MB more (337.29%) |
| Duckgres | Cold Build | 5m 31s | 3m 56s | 29% faster | n/a |
| Chroma | Warm Build | 63m 56s | 5m 24s | 92% faster | n/a |
| Linkerd2 Web | Warm Build | 0m 22s | 0m 15s | 32% faster | n/a |
| Qdrant | Cold Build | 15m 15s | 8m 11s | 46% faster | n/a |
| n8n | Cold Build | 2m 46s | 2m 31s | 9% faster | n/a |
| n8n Docker | Cold Build | 4m 57s | 3m 53s | 22% faster | n/a |
| n8n Runners | Cold Build | 1m 23s | 0m 41s | 51% faster | n/a |
| n8n Runners Distroless | Cold Build | 3m 10s | 1m 13s | 62% faster | n/a |

## Rolling

| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |
| --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 18s | 2m 52s | 13% faster | 80.31 MB less (18.77%) |
| Hugo Go | Commit Build | 0m 23s | 0m 30s | 30% slower | 471.28 MB less (76.54%) |
| OpenTelemetry Java | Commit Build | 1m 0s | 1m 11s | 18% slower | 957.32 MB less (47.17%) |
| Spring AI | Commit Build | 3m 56s | 3m 57s | near tie | 941.65 MB less (34.39%) |
| Chroma | Commit Build | 20m 21s | 10m 54s | 46% faster | n/a |
| Linkerd2 Web | Commit Build | 0m 16s | 0m 9s | 44% faster | n/a |
| n8n | Commit Build | 4m 11s | 3m 31s | 16% faster | 1.96 GB less (41.64%) |
