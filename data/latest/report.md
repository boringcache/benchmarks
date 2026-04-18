## Latest Benchmark Report

Generated: 2026-04-18 12:48 UTC

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
| Hugo | Run Total | 4m 48s | 3m 40s | 24% faster | 17.51 GB (93.22%) | cold, layer miss faster |
| Immich | Warm | 0m 13s | 0m 9s | near tie | 27.84 GB (87.15%) | cold, layer miss, run total faster |
| Mastodon | Cold | 10m 1s | 9m 22s | 6% faster | 28.76 GB (93.72%) | layer miss, run total faster |
| PostHog | Cold | 17m 35s | 15m 19s | 13% faster | 29.23 GB (100.0%) | layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 42s | 10m 30s | near tie | 49.26 MB (6.04%) | warm slower |
| Spring AI | Cold | 4m 54s | 4m 13s | 14% faster | 3.61 MB (0.36%) | mixed: warm slower; run total faster |
| gRPC | Cold | 32m 6s | 38m 5s | 19% slower | 362.66 MB (100.0%) | warm, run total slower |
| Zed | Warm | 17m 52s | 17m 23s | near tie | 2.08 GB (74.99%) | cold, run total slower |
| n8n | Cold | 5m 35s | 5m 2s | 10% faster | 16.71 MB more (-2.56%) | BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 9s | 3m 25s | 2178% slower | 15.46 GB (92.4%) | run total slower |
| Immich | Cold | 4m 38s | 5m 5s | 10% slower | 25.47 GB (85.37%) | run total slower |
| Mastodon | Cold | 2m 51s | 4m 20s | 52% slower | 27.67 GB (92.26%) | run total slower |
| PostHog | Cold | 10m 46s | 15m 7s | 40% slower | 12.33 GB (39.52%) | run total slower |
| OpenTelemetry Java | Cold | 1m 18s | 10m 24s | 700% slower | 939.20 MB (55.06%) | run total slower |
| Spring AI | Cold | 3m 3s | 4m 13s | 38% slower | 1.14 GB (54.22%) | run total slower |
| gRPC | Cold | 37m 33s | 29m 28s | 22% faster | 34.65 MB (3.09%) | run total faster |
| Zed | Cold | 38m 26s | 39m 41s | 3% slower | 10.74 GB (93.94%) | run total slower |
| n8n | Cold | 3m 3s | 3m 36s | 18% slower | 1.08 GB (62.46%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
