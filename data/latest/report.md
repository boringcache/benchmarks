## Latest Benchmark Report

Generated: 2026-04-21 16:49 UTC

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
| Immich | Cold | 7m 58s | 4m 29s | 44% faster | 6.40 GB (58.73%) | run total faster |
| Mastodon | Warm | 0m 18s | 0m 11s | 39% faster | 8.80 GB (81.25%) | cold, layer miss, run total faster |
| PostHog | Cold | 22m 13s | 13m 53s | 38% faster | 3.29 GB (21.99%) | run total faster |
| OpenTelemetry Java | Cold | 10m 26s | 10m 41s | near tie | 49.33 MB (6.05%) | warm, run total slower |
| Spring AI | Cold | 4m 29s | 4m 49s | 7% slower | 2.45 MB (0.25%) | warm, run total slower |
| gRPC | Warm | 36m 4s | 1m 52s | 95% faster | 740.29 MB more (-455.6%) | cold, run total faster; BC used more storage |
| Zed | Run Total | 58m 29s | 51m 46s | 11% faster | 2.08 GB (74.98%) | cold faster |
| n8n | Cold | 5m 13s | 5m 23s | 3% slower | 16.76 MB more (-2.55%) | warm, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 11s | 0m 11s | near tie | 9.07 GB (93.19%) | tiny run; setup dominates |
| Immich | Cold | 5m 15s | 3m 10s | 40% faster | 5.33 GB (54.22%) | run total faster |
| Mastodon | Cold | 2m 22s | 2m 8s | 10% faster | 7.95 GB (79.66%) | run total faster |
| PostHog | Cold | 18m 43s | 10m 46s | 42% faster | 2.05 GB (15.45%) | run total faster |
| OpenTelemetry Java | Cold | 8m 22s | 11m 40s | 39% slower | 1005.19 MB (56.74%) | run total slower |
| Spring AI | Cold | 3m 29s | 3m 29s | near tie | 1.72 GB (60.58%) | run total slower |
| gRPC | Cold | 36m 46s | 32m 7s | 13% faster | 581.80 MB more (-179.04%) | run total faster; BC used more storage |
| Zed | Run Total | 29m 3s | 23m 56s | 18% faster | 10.77 GB (93.9%) | — |
| n8n | Cold | 2m 34s | 2m 21s | 8% faster | 2.28 GB (77.64%) | run total faster |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
