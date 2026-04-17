## Latest Benchmark Report

Generated: 2026-04-17 09:03 UTC

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
| Mastodon | Cold | 10m 24s | 9m 1s | 13% faster | 28.75 GB (93.72%) | layer miss, run total faster |
| PostHog | Cold | 15m 53s | 12m 46s | 20% faster | 22.29 GB (67.16%) | mixed: warm slower; layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 40s | 10m 44s | near tie | 49.25 MB (6.04%) | — |
| Spring AI | Cold | 5m 20s | 4m 11s | 22% faster | 4.40 MB (0.44%) | run total faster |
| gRPC | Cold | 32m 6s | 38m 5s | 19% slower | 362.66 MB (100.0%) | warm, run total slower |
| Zed | Cold | 39m 8s | 49m 12s | 26% slower | 2.08 GB (74.98%) | run total slower |
| n8n | Cold | 5m 40s | 5m 10s | 9% faster | 16.76 MB more (-2.57%) | run total faster; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 4m 22s | 3m 33s | 19% faster | 13.97 GB (91.65%) | run total faster |
| Immich | Cold | 0m 4s | 16m 29s | 24625% slower | 26.46 GB (86.57%) | run total slower |
| Mastodon | Cold | 2m 11s | 3m 11s | 46% slower | 28.02 GB (92.35%) | run total slower |
| PostHog | Cold | 12m 18s | 14m 3s | 14% slower | 14.43 GB (47.76%) | run total slower |
| OpenTelemetry Java | Cold | 0m 39s | 10m 27s | 1508% slower | 939.18 MB (55.05%) | run total slower |
| Spring AI | Cold | 0m 24s | 4m 19s | 979% slower | 1003.84 MB (50.44%) | run total slower |
| gRPC | Cold | 0m 28s | 0m 41s | 46% slower | 115.25 MB (10.3%) | run total slower |
| Zed | Run Total | 19m 54s | 19m 39s | near tie | 6.11 GB (89.81%) | cold slower |
| n8n | Cold | 0m 41s | 5m 20s | 680% slower | 827.50 MB (55.28%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
