## Latest Benchmark Report

Generated: 2026-04-22 20:47 UTC

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
| Hugo | Cold | 3m 36s | 3m 23s | 6% faster | 9.12 GB (93.22%) | run total faster |
| Immich | Cold | 6m 8s | 4m 54s | 20% faster | 5.44 GB (54.52%) | run total faster |
| Mastodon | Cold | 11m 17s | 9m 4s | 20% faster | 8.69 GB (81.08%) | mixed: warm slower; run total faster |
| PostHog | Cold | 28m 41s | 14m 34s | 49% faster | 1.65 GB more (-16.39%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 9m 14s | 10m 30s | 14% slower | 49.26 MB (6.04%) | run total slower |
| Spring AI | Cold | 4m 58s | 4m 32s | 9% faster | 1.70 MB (0.18%) | run total slower |
| gRPC | Warm | 31m 28s | 1m 13s | 96% faster | 744.28 MB more (-458.06%) | cold, run total slower; BC used more storage |
| Zed | Cold | 49m 24s | 49m 57s | near tie | 2.30 GB (82.59%) | run total slower |
| n8n | Warm | 1m 10s | 0m 59s | 16% faster | 16.72 MB more (-2.54%) | cold, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Run Total | 0m 21s | 0m 18s | near tie | 9.12 GB (93.22%) | tiny run; setup dominates |
| Immich | Run Total | 0m 28s | 0m 20s | 29% faster | 5.32 GB (53.98%) | tiny run; setup dominates |
| Mastodon | Run Total | 0m 37s | 0m 26s | 30% faster | 7.95 GB (79.67%) | tiny run; setup dominates |
| PostHog | Cold | 23m 13s | 14m 17s | 38% faster | 2.52 GB (17.66%) | run total faster |
| OpenTelemetry Java | Cold | 0m 50s | 10m 54s | 1208% slower | 1.03 GB (57.99%) | run total slower |
| Spring AI | Cold | 0m 34s | 0m 37s | near tie | 2.00 GB (67.86%) | tiny run; setup dominates |
| gRPC | Cold | 36m 46s | 37m 16s | near tie | 579.12 MB more (-178.21%) | BC used more storage |
| Zed | Cold | 36m 39s | 37m 8s | near tie | 10.79 GB (93.94%) | — |
| n8n | Cold | 4m 4s | 4m 15s | 5% slower | 2.78 GB (80.87%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
