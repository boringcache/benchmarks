## Latest Benchmark Report

Generated: 2026-04-20 16:51 UTC

### Lane Coverage

| Benchmark | Fresh | Rolling |
| --- | --- | --- |
| Hugo | yes | yes |
| Immich | yes | yes |
| Mastodon | yes | yes |
| PostHog | yes | yes |
| OpenTelemetry Java | yes | yes |
| Spring AI | yes | yes |
| gRPC | yes | yes |
| Zed | yes | yes |
| n8n | yes | yes |

### Fresh Isolated

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 4m 14s | 3m 8s | 26% faster | 9.53 GB (93.49%) | mixed: layer miss slower; run total faster |
| Immich | Cold | 5m 9s | 4m 28s | 13% faster | 5.72 GB (57.27%) | mixed: warm, layer miss slower; run total faster |
| Mastodon | Cold | 10m 54s | 9m 5s | 17% faster | 9.56 GB (82.48%) | layer miss, run total faster |
| PostHog | Cold | 21m 32s | 14m 10s | 34% faster | 402.99 MB (3.22%) | run total faster |
| OpenTelemetry Java | Cold | 10m 26s | 10m 41s | near tie | 49.33 MB (6.05%) | warm, run total slower |
| Spring AI | Cold | 4m 36s | 4m 42s | near tie | 3.80 MB (0.39%) | — |
| gRPC | Warm | 37m 1s | 1m 39s | 96% faster | 739.66 MB more (-455.23%) | cold, run total faster; BC used more storage |
| Zed | Cold | 49m 11s | 48m 29s | near tie | 2.08 GB (74.99%) | warm slower |
| n8n | Cold | 4m 52s | 5m 20s | 10% slower | 16.82 MB more (-2.58%) | warm, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 2m 50s | 2m 47s | near tie | 9.19 GB (93.27%) | — |
| Immich | Cold | 0m 18s | 0m 11s | 39% faster | 6.35 GB (59.82%) | run total faster; tiny run; setup dominates |
| Mastodon | Cold | 2m 22s | 2m 9s | 9% faster | 7.93 GB (79.62%) | run total faster |
| PostHog | Cold | 15m 11s | 10m 55s | 28% faster | 1.28 GB more (-12.62%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 8m 22s | 11m 40s | 39% slower | 1005.19 MB (56.74%) | run total slower |
| Spring AI | Cold | 3m 21s | 4m 3s | 21% slower | 1.60 GB (62.9%) | run total slower |
| gRPC | Cold | 36m 29s | 1m 39s | 95% faster | 582.11 MB more (-179.13%) | run total faster; BC used more storage |
| Zed | Run Total | 45m 57s | 38m 39s | 16% faster | 10.77 GB (93.9%) | cold slower |
| n8n | Cold | 2m 34s | 2m 25s | 6% faster | 1.55 GB (70.4%) | — |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
