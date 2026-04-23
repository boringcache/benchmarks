## Latest Benchmark Report

Generated: 2026-04-23 01:09 UTC

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
| Hugo | Cold | 3m 36s | 3m 16s | 9% faster | 9.33 GB (93.36%) | run total faster |
| Immich | Cold | 6m 8s | 4m 54s | 20% faster | 5.44 GB (54.52%) | run total faster |
| Mastodon | Cold | 11m 17s | 9m 4s | 20% faster | 8.69 GB (81.08%) | mixed: warm slower; run total faster |
| PostHog | Warm | 2m 11s | 0m 14s | 89% faster | 5.96 GB (33.62%) | cold, run total faster |
| OpenTelemetry Java | Cold | 10m 56s | 8m 32s | 22% faster | 49.26 MB (6.04%) | mixed: warm slower; run total faster |
| Spring AI | Cold | 4m 58s | 4m 32s | 9% faster | 1.70 MB (0.18%) | run total slower |
| gRPC | Warm | 31m 28s | 1m 13s | 96% faster | 744.28 MB more (-458.06%) | cold, run total slower; BC used more storage |
| Zed | Cold | 48m 9s | 39m 30s | 18% faster | 2.09 GB (75.27%) | run total faster |
| n8n | Warm | 1m 10s | 0m 59s | 16% faster | 16.72 MB more (-2.54%) | cold, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 0s | 3m 15s | 8% slower | 9.33 GB (93.36%) | run total slower |
| Immich | Run Total | 0m 28s | 0m 20s | 29% faster | 5.32 GB (53.98%) | tiny run; setup dominates |
| Mastodon | Run Total | 0m 37s | 0m 26s | 30% faster | 7.95 GB (79.67%) | tiny run; setup dominates |
| PostHog | Cold | 16m 4s | 8m 9s | 49% faster | 2.54 GB more (-27.54%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 0m 50s | 10m 54s | 1208% slower | 1.03 GB (57.99%) | run total slower |
| Spring AI | Cold | 0m 34s | 0m 37s | near tie | 2.00 GB (67.86%) | tiny run; setup dominates |
| gRPC | Cold | 36m 46s | 37m 16s | near tie | 579.12 MB more (-178.21%) | BC used more storage |
| Zed | Run Total | 26m 21s | 26m 15s | near tie | 5.05 GB (88.02%) | cold slower |
| n8n | Cold | 4m 4s | 4m 15s | 5% slower | 2.78 GB (80.87%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
