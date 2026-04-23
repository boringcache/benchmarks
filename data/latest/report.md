## Latest Benchmark Report

Generated: 2026-04-23 12:51 UTC

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
| Hugo | Warm | 0m 12s | 0m 10s | near tie | 9.29 GB (93.33%) | cold, run total faster |
| Immich | Cold | 5m 49s | 4m 50s | 17% faster | 5.62 GB (55.35%) | run total faster |
| Mastodon | Cold | 9m 40s | 10m 20s | 7% slower | 8.27 GB (80.31%) | run total slower |
| PostHog | Cold | 30m 47s | 14m 8s | 54% faster | 1005.84 MB more (-9.1%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 8m 21s | 11m 8s | 33% slower | 49.45 MB (6.06%) | warm, run total slower |
| Spring AI | Cold | 4m 14s | 4m 26s | 5% slower | 3.15 MB (0.32%) | run total slower |
| gRPC | Warm | 37m 31s | 1m 15s | 97% faster | 744.28 MB more (-458.07%) | cold, run total faster; BC used more storage |
| Zed | Cold | 49m 8s | 50m 8s | near tie | 2.09 GB (75.28%) | — |
| n8n | Cold | 6m 11s | 5m 55s | 4% faster | 16.14 MB more (-2.44%) | warm slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 0s | 3m 15s | 8% slower | 9.33 GB (93.36%) | run total slower |
| Immich | Cold | 9m 7s | 4m 32s | 50% faster | 5.62 GB (55.35%) | run total faster |
| Mastodon | Cold | 2m 10s | 9m 41s | 347% slower | 7.95 GB (79.67%) | run total slower |
| PostHog | Cold | 15m 13s | 14m 11s | 7% faster | 895.71 MB (6.92%) | run total faster |
| OpenTelemetry Java | Cold | 0m 50s | 10m 54s | 1208% slower | 1.03 GB (57.99%) | run total slower |
| Spring AI | Cold | 0m 45s | 4m 25s | 489% slower | 2.00 GB (67.95%) | run total slower |
| gRPC | Cold | 36m 31s | 1m 20s | 96% faster | 581.99 MB more (-179.02%) | run total faster; BC used more storage |
| Zed | Run Total | 40m 11s | 38m 38s | 4% faster | 10.72 GB (93.97%) | — |
| n8n | Run Total | 5m 17s | 4m 47s | 9% faster | 3.30 GB (83.31%) | cold faster |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
