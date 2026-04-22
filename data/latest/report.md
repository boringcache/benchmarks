## Latest Benchmark Report

Generated: 2026-04-22 16:49 UTC

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
| Hugo | Cold | 4m 14s | 3m 16s | 23% faster | 9.40 GB (93.41%) | mixed: warm slower; run total faster |
| Immich | Cold | 10m 43s | 4m 41s | 56% faster | 4.89 GB (51.86%) | mixed: warm, layer miss slower; run total faster |
| Mastodon | Cold | 9m 56s | 9m 31s | 4% faster | 8.86 GB (81.36%) | mixed: warm slower; layer miss faster |
| PostHog | Cold | 20m 58s | 13m 49s | 34% faster | 235.37 MB more (-2.0%) | mixed: warm slower; layer miss, run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 11m 29s | 10m 17s | 10% faster | 49.29 MB (6.04%) | mixed: warm slower; run total faster |
| Spring AI | Cold | 4m 23s | 4m 15s | 3% faster | 3.47 MB (0.36%) | — |
| gRPC | Warm | 31m 28s | 1m 13s | 96% faster | 744.28 MB more (-458.06%) | cold, run total slower; BC used more storage |
| Zed | Run Total | 53m 45s | 51m 52s | 4% faster | 2.09 GB (75.25%) | — |
| n8n | Cold | 5m 21s | 6m 16s | 17% slower | 16.63 MB more (-2.52%) | warm, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 1s | 3m 0s | near tie | 9.06 GB (93.18%) | — |
| Immich | Cold | 0m 37s | 4m 56s | 700% slower | 4.89 GB (51.89%) | run total slower |
| Mastodon | Cold | 2m 10s | 9m 7s | 321% slower | 7.95 GB (79.66%) | run total slower |
| PostHog | Run Total | 35m 1s | 14m 38s | 58% faster | 235.30 MB more (-2.0%) | cold faster; BC used more storage |
| OpenTelemetry Java | Cold | 1m 40s | 10m 39s | 539% slower | 1.03 GB (57.99%) | run total slower |
| Spring AI | Cold | 0m 34s | 0m 37s | near tie | 2.00 GB (67.86%) | tiny run; setup dominates |
| gRPC | Cold | 36m 46s | 37m 16s | near tie | 579.12 MB more (-178.21%) | BC used more storage |
| Zed | Run Total | 44m 13s | 42m 28s | 4% faster | 9.73 GB (93.32%) | — |
| n8n | Cold | 4m 4s | 4m 15s | 5% slower | 2.78 GB (80.87%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
