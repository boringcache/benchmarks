## Latest Benchmark Report

Generated: 2026-04-16 20:46 UTC

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
| PostHog | Run Total | 18m 48s | 15m 31s | 17% faster | 23.06 GB (67.9%) | mixed: warm slower; cold, layer miss faster |
| OpenTelemetry Java | Warm | 0m 37s | 0m 35s | near tie | 49.18 MB (6.03%) | cold faster |
| Spring AI | Cold | 5m 20s | 4m 11s | 22% faster | 4.40 MB (0.44%) | run total faster |
| gRPC | Cold | 27m 45s | 39m 40s | 43% slower | 362.35 MB (100.0%) | warm, run total slower |
| Zed | Run Total | 51m 10s | 49m 51s | near tie | 2.08 GB (74.97%) | warm slower |
| n8n | Cold | 5m 40s | 5m 10s | 9% faster | 16.76 MB more (-2.57%) | run total faster; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 30s | 1m 55s | 45% faster | 13.64 GB (89.47%) | layer miss, run total faster |
| Immich | Run Total | 13m 21s | 6m 59s | 48% faster | 25.59 GB (85.41%) | mixed: cold slower; layer miss faster |
| Mastodon | Cold | 2m 22s | 9m 22s | 296% slower | 26.84 GB (93.3%) | mixed: run total slower; layer miss faster |
| PostHog | Cold | 17m 14s | 12m 57s | 25% faster | 18.61 GB (54.81%) | run total faster |
| OpenTelemetry Java | Cold | 0m 40s | 8m 41s | 1203% slower | 864.95 MB (53.02%) | run total slower |
| Spring AI | Warm | 0m 23s | 0m 20s | near tie | 1000.00 MB (50.25%) | cold, run total slower |
| gRPC | Cold | 30m 59s | 38m 5s | 23% slower | 723.02 MB (100.0%) | warm, run total slower |
| Zed | Cold | 40m 13s | 38m 9s | 5% faster | 5.77 GB (89.28%) | — |
| n8n | Cold | 2m 48s | 3m 4s | 10% slower | 815.00 MB (55.02%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
