## Latest Benchmark Report

Generated: 2026-04-19 08:48 UTC

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
| Hugo | Cold | 4m 17s | 3m 27s | 19% faster | 21.20 GB (94.34%) | layer miss, run total faster |
| Immich | Cold | 25m 10s | 15m 54s | 37% faster | 28.37 GB (87.36%) | layer miss, run total faster |
| Mastodon | Run Total | 11m 41s | 9m 37s | 18% faster | 28.82 GB (93.74%) | cold, layer miss faster |
| PostHog | Run Total | 18m 28s | 16m 4s | 13% faster | 19.08 GB (63.66%) | cold, layer miss faster |
| OpenTelemetry Java | Cold | 10m 40s | 10m 43s | near tie | 49.39 MB (6.05%) | — |
| Spring AI | Cold | 4m 20s | 4m 27s | near tie | 3.60 MB (0.36%) | warm, run total slower |
| gRPC | Cold | 32m 6s | 38m 5s | 19% slower | 362.66 MB (100.0%) | warm, run total slower |
| Zed | Cold | 48m 13s | 49m 28s | near tie | 2.08 GB (75.0%) | warm, run total slower |
| n8n | Warm | 2m 5s | 1m 1s | 51% faster | 16.66 MB more (-2.55%) | cold faster; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 30s | 1m 32s | 56% faster | 19.94 GB (92.6%) | run total faster |
| Immich | Cold | 0m 8s | 4m 49s | 3513% slower | 26.86 GB (86.75%) | run total slower |
| Mastodon | Cold | 3m 25s | 3m 35s | 5% slower | 28.67 GB (93.27%) | run total slower |
| PostHog | Cold | 10m 55s | 12m 14s | 12% slower | 9.55 GB (31.85%) | — |
| OpenTelemetry Java | Cold | 0m 40s | 1m 6s | 65% slower | 960.79 MB (55.55%) | run total slower |
| Spring AI | Cold | 0m 34s | 1m 33s | 174% slower | 1.13 GB (49.8%) | run total slower |
| gRPC | Cold | 31m 55s | 11m 18s | 65% faster | 290.93 MB more (-25.75%) | run total faster; BC used more storage |
| Zed | Cold | 18m 21s | 19m 59s | 9% slower | 5.00 GB (87.72%) | run total slower |
| n8n | Cold | 1m 14s | 1m 2s | 16% faster | 1.18 GB (64.45%) | run total faster |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
