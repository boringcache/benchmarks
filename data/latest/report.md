## Latest Benchmark Report

Generated: 2026-04-19 20:45 UTC

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
| PostHog | Cold | 18m 22s | 13m 5s | 29% faster | 22.43 GB (67.4%) | layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 55s | 10m 35s | 3% faster | 49.28 MB (6.04%) | warm slower |
| Spring AI | Cold | 4m 6s | 4m 45s | 16% slower | 3.59 MB (0.36%) | warm, run total slower |
| gRPC | Warm | 28m 6s | 3m 13s | 89% faster | 742.29 MB more (-456.84%) | cold, run total slower; BC used more storage |
| Zed | Warm | 16m 53s | 16m 39s | near tie | 2.08 GB (75.0%) | — |
| n8n | Cold | 5m 17s | 5m 21s | near tie | 16.72 MB more (-2.56%) | warm, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 31s | 3m 15s | 8% faster | 21.26 GB (93.03%) | run total faster |
| Immich | Cold | 0m 11s | 0m 15s | near tie | 25.63 GB (85.45%) | run total slower; tiny run; setup dominates |
| Mastodon | Cold | 0m 15s | 2m 53s | 1053% slower | 27.64 GB (92.2%) | run total slower |
| PostHog | Cold | 12m 17s | 12m 35s | near tie | 10.38 GB (33.56%) | run total slower |
| OpenTelemetry Java | Cold | 0m 41s | 1m 0s | 46% slower | 960.84 MB (55.55%) | run total slower |
| Spring AI | Cold | 0m 32s | 1m 11s | 122% slower | 1.13 GB (49.8%) | run total slower |
| gRPC | Cold | 36m 21s | 38m 26s | 6% slower | 1.08 GB more (-678.56%) | run total slower; BC used more storage |
| Zed | Cold | 17m 14s | 20m 14s | 17% slower | 6.04 GB (89.62%) | run total slower |
| n8n | Cold | 1m 6s | 0m 57s | 14% faster | 1.18 GB (64.49%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
