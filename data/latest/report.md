## Latest Benchmark Report

Generated: 2026-04-22 05:18 UTC

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
| Hugo | Run Total | 4m 7s | 3m 18s | 20% faster | 9.32 GB (93.36%) | mixed: warm slower; cold, layer miss faster |
| Immich | Cold | 7m 16s | 4m 32s | 38% faster | 5.33 GB (54.21%) | mixed: warm slower; layer miss, run total faster |
| Mastodon | Cold | 9m 40s | 9m 14s | 4% faster | 10.86 GB (100.0%) | mixed: warm slower; layer miss, run total faster |
| PostHog | Warm | 8m 30s | 6m 40s | 22% faster | 1.38 GB more (-13.39%) | mixed: layer miss slower; cold, run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 10m 26s | 10m 55s | 5% slower | 49.26 MB (6.04%) | run total slower |
| Spring AI | Cold | 4m 19s | 4m 26s | near tie | 3.48 MB (0.36%) | warm, run total slower |
| gRPC | Warm | 36m 51s | 1m 12s | 97% faster | 744.28 MB more (-458.07%) | cold, run total slower; BC used more storage |
| Zed | Run Total | 57m 49s | 53m 2s | 8% faster | 2.08 GB (74.99%) | warm slower |
| n8n | Cold | 5m 25s | 5m 29s | near tie | 16.79 MB more (-2.55%) | warm slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 9s | 3m 13s | 2044% slower | 9.07 GB (93.19%) | run total slower |
| Immich | Cold | 0m 17s | 4m 33s | 1506% slower | 5.28 GB (53.96%) | run total slower |
| Mastodon | Cold | 0m 11s | 8m 34s | 4573% slower | 7.96 GB (79.68%) | run total slower |
| PostHog | Cold | 19m 38s | 14m 0s | 29% faster | 7.25 GB (38.21%) | run total faster |
| OpenTelemetry Java | Cold | 5m 14s | 10m 33s | 102% slower | 1.03 GB (57.85%) | run total slower |
| Spring AI | Cold | 0m 34s | 0m 37s | near tie | 2.00 GB (67.86%) | tiny run; setup dominates |
| gRPC | Cold | 27m 56s | 36m 45s | 32% slower | 581.80 MB more (-179.04%) | run total slower; BC used more storage |
| Zed | Cold | 31m 48s | 33m 5s | 4% slower | 10.76 GB (93.95%) | — |
| n8n | Cold | 1m 16s | 5m 28s | 332% slower | 2.29 GB (77.66%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
