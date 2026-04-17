## Latest Benchmark Report

Generated: 2026-04-17 01:08 UTC

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
| Hugo | Run Total | 4m 31s | 3m 47s | 16% faster | 13.97 GB (91.65%) | cold, layer miss faster |
| Immich | Cold | 21m 6s | 15m 49s | 25% faster | 25.99 GB (86.37%) | layer miss, run total faster |
| Mastodon | Run Total | 11m 49s | 10m 36s | 10% faster | 25.01 GB (92.85%) | cold, layer miss faster |
| PostHog | Run Total | 21m 45s | 15m 0s | 31% faster | 20.45 GB (65.2%) | mixed: warm slower; cold, layer miss faster |
| OpenTelemetry Java | Cold | 10m 40s | 10m 44s | near tie | 49.25 MB (6.04%) | — |
| Spring AI | Cold | 5m 20s | 4m 11s | 22% faster | 4.40 MB (0.44%) | run total faster |
| gRPC | Cold | 27m 45s | 39m 40s | 43% slower | 362.35 MB (100.0%) | warm, run total slower |
| Zed | Run Total | 51m 15s | 50m 28s | near tie | 2.08 GB (74.97%) | — |
| n8n | Cold | 5m 40s | 5m 10s | 9% faster | 16.76 MB more (-2.57%) | run total faster; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 30s | 1m 55s | 45% faster | 13.64 GB (89.47%) | layer miss, run total faster |
| Immich | Run Total | 13m 21s | 6m 59s | 48% faster | 25.59 GB (85.41%) | mixed: cold slower; layer miss faster |
| Mastodon | Cold | 2m 22s | 9m 22s | 296% slower | 26.84 GB (93.3%) | mixed: run total slower; layer miss faster |
| PostHog | Cold | 8m 1s | 11m 57s | 49% slower | 14.00 GB (47.18%) | run total slower |
| OpenTelemetry Java | Cold | 7m 6s | 10m 34s | 49% slower | 902.27 MB (54.07%) | run total slower |
| Spring AI | Warm | 0m 23s | 0m 20s | near tie | 1000.00 MB (50.25%) | cold, run total slower |
| gRPC | Cold | 30m 59s | 38m 5s | 23% slower | 723.02 MB (100.0%) | warm, run total slower |
| Zed | Run Total | 35m 24s | 35m 13s | near tie | 5.38 GB (88.58%) | warm slower |
| n8n | Cold | 2m 48s | 3m 4s | 10% slower | 815.00 MB (55.02%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
