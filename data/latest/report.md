## Latest Benchmark Report

Generated: 2026-04-20 05:28 UTC

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
| Hugo | Cold | 3m 56s | 3m 55s | near tie | 22.52 GB (94.65%) | layer miss faster |
| Immich | Warm | 0m 8s | 0m 7s | near tie | 27.23 GB (86.9%) | cold, layer miss, run total faster |
| Mastodon | Cold | 9m 45s | 9m 47s | near tie | 28.72 GB (93.71%) | layer miss faster |
| PostHog | Warm | 0m 17s | 0m 12s | near tie | 20.91 GB (65.86%) | cold, layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 55s | 10m 35s | 3% faster | 49.28 MB (6.04%) | warm slower |
| Spring AI | Cold | 4m 6s | 4m 45s | 16% slower | 3.59 MB (0.36%) | warm, run total slower |
| gRPC | Warm | 28m 6s | 3m 13s | 89% faster | 742.29 MB more (-456.84%) | cold, run total slower; BC used more storage |
| Zed | Cold | 49m 17s | 49m 2s | near tie | 2.08 GB (75.0%) | warm, run total slower |
| n8n | Cold | 5m 17s | 5m 21s | near tie | 16.72 MB more (-2.56%) | warm, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 9s | 3m 26s | 2189% slower | 22.20 GB (93.31%) | run total slower |
| Immich | Cold | 0m 11s | 0m 50s | 355% slower | 25.36 GB (85.32%) | run total slower |
| Mastodon | Cold | 0m 19s | 0m 50s | 163% slower | 27.98 GB (93.56%) | run total slower |
| PostHog | Cold | 14m 39s | 11m 35s | 21% faster | 16.73 GB (50.13%) | run total faster |
| OpenTelemetry Java | Cold | 0m 41s | 1m 0s | 46% slower | 960.84 MB (55.55%) | run total slower |
| Spring AI | Cold | 0m 32s | 1m 11s | 122% slower | 1.13 GB (49.8%) | run total slower |
| gRPC | Cold | 36m 21s | 38m 26s | 6% slower | 1.08 GB more (-678.56%) | run total slower; BC used more storage |
| Zed | Cold | 17m 14s | 20m 14s | 17% slower | 6.04 GB (89.62%) | run total slower |
| n8n | Cold | 1m 6s | 0m 57s | 14% faster | 1.18 GB (64.49%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
