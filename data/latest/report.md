## Latest Benchmark Report

Generated: 2026-04-21 09:07 UTC

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
| Immich | Cold | 4m 56s | 4m 21s | 12% faster | 7.42 GB (63.47%) | mixed: warm, layer miss slower; run total faster |
| Mastodon | Warm | 0m 12s | 0m 10s | near tie | 8.82 GB (81.3%) | cold, layer miss, run total faster |
| PostHog | Cold | 20m 38s | 13m 44s | 33% faster | 80.81 MB more (-0.68%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 10m 26s | 10m 41s | near tie | 49.33 MB (6.05%) | warm, run total slower |
| Spring AI | Cold | 4m 16s | 3m 50s | 10% faster | 3.84 MB (0.4%) | warm, run total slower |
| gRPC | Warm | 36m 4s | 1m 52s | 95% faster | 740.29 MB more (-455.6%) | cold, run total faster; BC used more storage |
| Zed | Cold | 47m 20s | 48m 20s | near tie | 2.08 GB (75.0%) | warm, run total slower |
| n8n | Cold | 5m 7s | 5m 17s | 3% slower | 16.76 MB more (-2.57%) | run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 11s | 0m 11s | near tie | 9.07 GB (93.19%) | tiny run; setup dominates |
| Immich | Cold | 0m 9s | 0m 9s | near tie | 5.29 GB (55.33%) | tiny run; setup dominates |
| Mastodon | Cold | 0m 19s | 0m 15s | near tie | 7.94 GB (79.64%) | tiny run; setup dominates |
| PostHog | Cold | 16m 27s | 13m 50s | 16% faster | 780.30 MB (6.13%) | run total faster |
| OpenTelemetry Java | Cold | 8m 22s | 11m 40s | 39% slower | 1005.19 MB (56.74%) | run total slower |
| Spring AI | Cold | 0m 32s | 4m 1s | 653% slower | 1.89 GB (66.61%) | run total slower |
| gRPC | Cold | 36m 46s | 32m 7s | 13% faster | 581.80 MB more (-179.04%) | run total faster; BC used more storage |
| Zed | Cold | 39m 28s | 40m 3s | near tie | 6.98 GB (90.89%) | run total slower |
| n8n | Cold | 3m 14s | 1m 59s | 39% faster | 1.87 GB (74.23%) | run total faster |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
