## Latest Benchmark Report

Generated: 2026-04-22 12:51 UTC

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
| Hugo | Cold | 3m 44s | 7m 40s | 105% slower | 9.27 GB (93.32%) | warm, run total slower |
| Immich | Cold | 5m 32s | 4m 32s | 18% faster | 6.20 GB (57.92%) | mixed: warm slower; layer miss, run total faster |
| Mastodon | Cold | 9m 38s | 9m 33s | near tie | 8.76 GB (81.19%) | mixed: warm slower; layer miss faster |
| PostHog | Cold | 20m 5s | 14m 16s | 29% faster | 1.77 GB more (-17.78%) | mixed: warm slower; layer miss, run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 10m 29s | 10m 50s | 3% slower | 49.37 MB (6.05%) | warm slower |
| Spring AI | Cold | 4m 23s | 4m 15s | 3% faster | 3.47 MB (0.36%) | — |
| gRPC | Warm | 35m 52s | 1m 16s | 96% faster | 743.54 MB more (-457.61%) | cold, run total slower; BC used more storage |
| Zed | Cold | 47m 2s | 51m 9s | 9% slower | 2.08 GB (74.99%) | warm, run total slower |
| n8n | Cold | 5m 19s | 4m 52s | 8% faster | 16.69 MB more (-2.53%) | warm slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 9s | 3m 13s | 2044% slower | 9.07 GB (93.19%) | run total slower |
| Immich | Cold | 0m 17s | 4m 33s | 1506% slower | 5.28 GB (53.96%) | run total slower |
| Mastodon | Cold | 2m 7s | 8m 48s | 316% slower | 7.95 GB (79.67%) | run total slower |
| PostHog | Cold | 21m 11s | 14m 29s | 32% faster | 1.94 GB more (-19.77%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 5m 14s | 10m 33s | 102% slower | 1.03 GB (57.85%) | run total slower |
| Spring AI | Cold | 0m 34s | 0m 37s | near tie | 2.00 GB (67.86%) | tiny run; setup dominates |
| gRPC | Cold | 36m 22s | 0m 50s | 98% faster | 581.99 MB more (-179.02%) | run total faster; BC used more storage |
| Zed | Cold | 48m 42s | 35m 34s | 27% faster | 2.08 GB (74.99%) | run total faster |
| n8n | Cold | 2m 40s | 2m 27s | 8% faster | 2.73 GB (80.62%) | run total faster |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
