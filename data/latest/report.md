## Latest Benchmark Report

Generated: 2026-04-23 05:20 UTC

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
| Immich | Cold | 5m 41s | 4m 36s | 19% faster | 5.42 GB (54.42%) | run total faster |
| Mastodon | Cold | 10m 27s | 9m 17s | 11% faster | 7.96 GB (79.69%) | mixed: warm slower; run total faster |
| PostHog | Cold | 26m 1s | 18m 44s | 28% faster | 1.83 GB more (-18.43%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 8m 21s | 11m 8s | 33% slower | 49.45 MB (6.06%) | warm, run total slower |
| Spring AI | Cold | 4m 58s | 4m 14s | 15% faster | 3.48 MB (0.36%) | mixed: warm slower; run total faster |
| gRPC | Warm | 31m 20s | 1m 46s | 94% faster | 744.28 MB more (-458.07%) | cold, run total slower; BC used more storage |
| Zed | Run Total | 51m 52s | 49m 28s | 5% faster | 2.09 GB (75.28%) | — |
| n8n | Cold | 5m 30s | 7m 14s | 32% slower | 16.73 MB more (-2.54%) | warm, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 0s | 3m 15s | 8% slower | 9.33 GB (93.36%) | run total slower |
| Immich | Run Total | 0m 28s | 0m 20s | 29% faster | 5.32 GB (53.98%) | tiny run; setup dominates |
| Mastodon | Run Total | 0m 37s | 0m 26s | 30% faster | 7.95 GB (79.67%) | tiny run; setup dominates |
| PostHog | Cold | 13m 11s | 21m 48s | 65% slower | 11.36 GB (100.0%) | run total slower |
| OpenTelemetry Java | Cold | 0m 50s | 10m 54s | 1208% slower | 1.03 GB (57.99%) | run total slower |
| Spring AI | Cold | 0m 34s | 0m 37s | near tie | 2.00 GB (67.86%) | tiny run; setup dominates |
| gRPC | Cold | 31m 44s | 28m 9s | 11% faster | 581.68 MB more (-178.93%) | run total faster; BC used more storage |
| Zed | Cold | 39m 15s | 40m 47s | 4% slower | 6.08 GB (96.76%) | run total slower |
| n8n | Cold | 4m 4s | 4m 15s | 5% slower | 2.78 GB (80.87%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
