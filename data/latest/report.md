## Latest Benchmark Report

Generated: 2026-04-17 05:20 UTC

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
| PostHog | Cold | 16m 49s | 13m 16s | 21% faster | 19.09 GB (63.65%) | mixed: warm slower; layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 40s | 10m 44s | near tie | 49.25 MB (6.04%) | — |
| Spring AI | Cold | 5m 20s | 4m 11s | 22% faster | 4.40 MB (0.44%) | run total faster |
| gRPC | Cold | 32m 6s | 38m 5s | 19% slower | 362.66 MB (100.0%) | warm, run total slower |
| Zed | Cold | 50m 17s | 39m 18s | 22% faster | 2.08 GB (74.97%) | run total faster |
| n8n | Cold | 5m 40s | 5m 10s | 9% faster | 16.76 MB more (-2.57%) | run total faster; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 30s | 1m 55s | 45% faster | 13.64 GB (89.47%) | layer miss, run total faster |
| Immich | Run Total | 13m 21s | 6m 59s | 48% faster | 25.59 GB (85.41%) | mixed: cold slower; layer miss faster |
| Mastodon | Cold | 2m 22s | 9m 22s | 296% slower | 26.84 GB (93.3%) | mixed: run total slower; layer miss faster |
| PostHog | Cold | 9m 16s | 11m 59s | 29% slower | 14.68 GB (48.94%) | run total slower |
| OpenTelemetry Java | Cold | 7m 6s | 10m 34s | 49% slower | 902.27 MB (54.07%) | run total slower |
| Spring AI | Warm | 0m 23s | 0m 20s | near tie | 1000.00 MB (50.25%) | cold, run total slower |
| gRPC | Cold | 0m 16s | 39m 48s | 14825% slower | 721.79 MB (100.0%) | warm, run total slower |
| Zed | Cold | 21m 2s | 22m 1s | 5% slower | 5.99 GB (89.64%) | warm, run total slower |
| n8n | Cold | 2m 48s | 3m 4s | 10% slower | 815.00 MB (55.02%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
