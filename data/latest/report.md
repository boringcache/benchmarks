## Latest Benchmark Report

Generated: 2026-04-21 12:51 UTC

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
| Hugo | Run Total | 4m 0s | 3m 19s | 17% faster | 9.45 GB (93.44%) | cold faster |
| Immich | Cold | 5m 17s | 4m 16s | 19% faster | 6.75 GB (61.24%) | run total faster |
| Mastodon | Cold | 10m 15s | 8m 50s | 14% faster | 8.74 GB (81.15%) | mixed: warm slower; layer miss, run total faster |
| PostHog | Cold | 22m 12s | 14m 3s | 37% faster | 139.06 MB more (-1.18%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 10m 26s | 10m 41s | near tie | 49.33 MB (6.05%) | warm, run total slower |
| Spring AI | Cold | 4m 29s | 4m 49s | 7% slower | 2.45 MB (0.25%) | warm, run total slower |
| gRPC | Warm | 36m 4s | 1m 52s | 95% faster | 740.29 MB more (-455.6%) | cold, run total faster; BC used more storage |
| Zed | Cold | 48m 26s | 48m 19s | near tie | 2.08 GB (75.0%) | — |
| n8n | Cold | 5m 1s | 5m 45s | 15% slower | 16.88 MB more (-2.56%) | warm, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 11s | 0m 11s | near tie | 9.07 GB (93.19%) | tiny run; setup dominates |
| Immich | Cold | 4m 48s | 4m 57s | 3% slower | 6.75 GB (61.24%) | run total slower |
| Mastodon | Cold | 2m 28s | 1m 53s | 24% faster | 7.84 GB (79.44%) | run total faster |
| PostHog | Cold | 12m 10s | 10m 31s | 14% faster | 1.03 GB more (-10.07%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 8m 22s | 11m 40s | 39% slower | 1005.19 MB (56.74%) | run total slower |
| Spring AI | Cold | 3m 29s | 3m 29s | near tie | 1.72 GB (60.58%) | run total slower |
| gRPC | Cold | 36m 46s | 32m 7s | 13% faster | 581.80 MB more (-179.04%) | run total faster; BC used more storage |
| Zed | Run Total | 28m 14s | 20m 7s | 29% faster | 5.04 GB (87.82%) | cold faster |
| n8n | Cold | 3m 43s | 3m 24s | 9% faster | 2.11 GB (76.3%) | run total faster |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
