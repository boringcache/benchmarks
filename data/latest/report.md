## Latest Benchmark Report

Generated: 2026-04-18 20:46 UTC

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
| Hugo | Warm | 0m 7s | 0m 6s | near tie | 18.42 GB (93.54%) | layer miss faster |
| Immich | Cold | 16m 35s | 16m 1s | 3% faster | 27.61 GB (87.06%) | layer miss faster |
| Mastodon | Warm | 0m 12s | 0m 9s | near tie | 28.73 GB (93.72%) | cold, layer miss, run total faster |
| PostHog | Warm | 0m 23s | 0m 13s | 43% faster | 23.07 GB (67.95%) | cold, layer miss, run total faster |
| OpenTelemetry Java | Cold | 8m 31s | 10m 42s | 26% slower | 49.28 MB (6.04%) | warm, run total slower |
| Spring AI | Cold | 4m 23s | 4m 6s | 6% faster | 3.59 MB (0.36%) | run total faster |
| gRPC | Cold | 32m 6s | 38m 5s | 19% slower | 362.66 MB (100.0%) | warm, run total slower |
| Zed | Warm | 17m 52s | 17m 23s | near tie | 2.08 GB (74.99%) | cold, run total slower |
| n8n | Warm | 1m 7s | 1m 0s | 10% faster | 16.73 MB more (-2.56%) | run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 21s | 0m 11s | 48% faster | 17.53 GB (91.67%) | run total faster; tiny run; setup dominates |
| Immich | Run Total | 0m 32s | 0m 20s | 38% faster | 25.49 GB (85.38%) | cold faster; tiny run; setup dominates |
| Mastodon | Run Total | 0m 28s | 0m 20s | 29% faster | 28.07 GB (93.58%) | tiny run; setup dominates |
| PostHog | Cold | 12m 47s | 15m 0s | 17% slower | 11.27 GB (35.56%) | run total slower |
| OpenTelemetry Java | Cold | 0m 45s | 1m 4s | 42% slower | 939.33 MB (55.07%) | run total slower |
| Spring AI | Cold | 0m 31s | 0m 34s | near tie | 1.30 GB (57.47%) | run total slower |
| gRPC | Cold | 36m 50s | 24m 51s | 33% faster | 37.36 MB (3.32%) | run total faster |
| Zed | Cold | 17m 32s | 17m 48s | near tie | 10.70 GB (93.92%) | — |
| n8n | Cold | 1m 8s | 1m 12s | 6% slower | 1.12 GB (63.32%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
