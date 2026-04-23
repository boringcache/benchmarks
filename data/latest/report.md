## Latest Benchmark Report

Generated: 2026-04-23 09:08 UTC

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
| Mastodon | Cold | 9m 55s | 9m 13s | 7% faster | 8.27 GB (80.3%) | mixed: warm slower; run total faster |
| PostHog | Cold | 17m 20s | 14m 30s | 16% faster | 3.53 GB (23.12%) | run total faster |
| OpenTelemetry Java | Cold | 8m 21s | 11m 8s | 33% slower | 49.45 MB (6.06%) | warm, run total slower |
| Spring AI | Cold | 3m 35s | 4m 29s | 25% slower | 3.16 MB (0.33%) | warm, run total slower |
| gRPC | Warm | 36m 11s | 8m 44s | 76% faster | 428.89 MB more (-263.76%) | cold, run total faster; BC used more storage |
| Zed | Warm | 17m 46s | 17m 40s | near tie | 2.09 GB (75.27%) | — |
| n8n | Cold | 5m 31s | 5m 30s | near tie | 16.56 MB more (-2.52%) | warm, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 0s | 3m 15s | 8% slower | 9.33 GB (93.36%) | run total slower |
| Immich | Run Total | 0m 28s | 0m 20s | 29% faster | 5.32 GB (53.98%) | tiny run; setup dominates |
| Mastodon | Cold | 2m 9s | 9m 12s | 328% slower | 7.95 GB (79.66%) | run total slower |
| PostHog | Cold | 23m 23s | 12m 34s | 46% faster | 145.47 MB more (-1.22%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 0m 50s | 10m 54s | 1208% slower | 1.03 GB (57.99%) | run total slower |
| Spring AI | Cold | 0m 34s | 0m 37s | near tie | 2.00 GB (67.86%) | tiny run; setup dominates |
| gRPC | Cold | 37m 40s | 1m 14s | 97% faster | 581.87 MB more (-178.92%) | run total faster; BC used more storage |
| Zed | Run Total | 39m 19s | 39m 1s | near tie | 4.58 GB (86.94%) | — |
| n8n | Run Total | 4m 58s | 4m 47s | 4% faster | 3.00 GB (82.05%) | — |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
