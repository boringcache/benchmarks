## Latest Benchmark Report

Generated: 2026-04-20 09:15 UTC

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
| Mastodon | Cold | 9m 32s | 9m 16s | near tie | 28.85 GB (93.74%) | layer miss faster |
| PostHog | Cold | 17m 21s | 14m 6s | 19% faster | 20.72 GB (65.59%) | layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 55s | 10m 35s | 3% faster | 49.28 MB (6.04%) | warm slower |
| Spring AI | Cold | 4m 6s | 4m 45s | 16% slower | 3.59 MB (0.36%) | warm, run total slower |
| gRPC | Warm | 36m 43s | 1m 13s | 97% faster | 744.28 MB more (-458.07%) | run total faster; BC used more storage |
| Zed | Cold | 47m 39s | 40m 13s | 16% faster | 2.08 GB (74.99%) | mixed: warm slower; run total faster |
| n8n | Cold | 5m 48s | 5m 31s | 5% faster | 16.75 MB more (-2.57%) | mixed: warm slower; run total faster; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 38s | 3m 45s | 3% slower | 21.94 GB (94.52%) | run total slower |
| Immich | Cold | 0m 11s | 0m 50s | 355% slower | 25.36 GB (85.32%) | run total slower |
| Mastodon | Cold | 3m 2s | 2m 21s | 23% faster | 27.84 GB (93.11%) | run total faster |
| PostHog | Run Total | 20m 59s | 17m 7s | 18% faster | 9.90 GB (33.04%) | cold faster |
| OpenTelemetry Java | Cold | 0m 41s | 1m 0s | 46% slower | 960.84 MB (55.55%) | run total slower |
| Spring AI | Cold | 0m 32s | 1m 11s | 122% slower | 1.13 GB (49.8%) | run total slower |
| gRPC | Cold | 31m 24s | 32m 19s | near tie | 574.94 MB more (-176.93%) | run total slower; BC used more storage |
| Zed | Cold | 27m 7s | 26m 59s | near tie | 3.06 GB (81.39%) | — |
| n8n | Cold | 4m 24s | 4m 0s | 9% faster | 1.24 GB (65.66%) | run total faster |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
