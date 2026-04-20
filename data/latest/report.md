## Latest Benchmark Report

Generated: 2026-04-20 15:57 UTC

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
| Hugo | Cold | 3m 24s | 3m 13s | 5% faster | 9.10 GB (93.2%) | layer miss slower |
| Immich | Cold | 5m 9s | 4m 28s | 13% faster | 5.72 GB (57.27%) | mixed: warm, layer miss slower; run total faster |
| Mastodon | Cold | 10m 54s | 9m 5s | 17% faster | 9.56 GB (82.48%) | layer miss, run total faster |
| PostHog | Cold | 19m 21s | 14m 31s | 25% faster | 1.68 GB (12.41%) | mixed: layer miss slower; run total faster |
| OpenTelemetry Java | Cold | 10m 26s | 10m 41s | near tie | 49.33 MB (6.05%) | warm, run total slower |
| Spring AI | Cold | 4m 36s | 4m 42s | near tie | 3.80 MB (0.39%) | — |
| gRPC | Warm | 37m 1s | 1m 39s | 96% faster | 739.66 MB more (-455.23%) | cold, run total faster; BC used more storage |
| Zed | Run Total | 56m 57s | 50m 53s | 11% faster | 2.08 GB (74.99%) | mixed: warm slower; cold faster |
| n8n | Cold | 5m 47s | 5m 7s | 12% faster | 16.74 MB more (-2.56%) | mixed: warm slower; run total faster; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 2m 46s | 3m 20s | 20% slower | 9.10 GB (93.2%) | run total slower |
| Immich | Cold | 0m 18s | 0m 11s | 39% faster | 6.35 GB (59.82%) | run total faster; tiny run; setup dominates |
| Mastodon | Cold | 10m 27s | 9m 3s | 13% faster | 7.79 GB (79.33%) | run total faster |
| PostHog | Run Total | 13m 59s | 12m 1s | 14% faster | 1.60 GB more (-16.35%) | cold faster; BC used more storage |
| OpenTelemetry Java | Cold | 8m 22s | 11m 40s | 39% slower | 1005.19 MB (56.74%) | run total slower |
| Spring AI | Cold | 3m 21s | 4m 3s | 21% slower | 1.60 GB (62.9%) | run total slower |
| gRPC | Cold | 36m 29s | 1m 39s | 95% faster | 582.11 MB more (-179.13%) | run total faster; BC used more storage |
| Zed | Run Total | 30m 30s | 28m 59s | 5% faster | 5.04 GB (87.82%) | — |
| n8n | Cold | 2m 26s | 2m 23s | near tie | 1.49 GB (69.55%) | — |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
