## Latest Benchmark Report

Generated: 2026-04-17 12:49 UTC

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
| Hugo | Cold | 4m 34s | 3m 57s | 14% faster | 16.05 GB (92.65%) | layer miss, run total faster |
| Immich | Run Total | 20m 41s | 15m 35s | 25% faster | 27.82 GB (87.15%) | cold, layer miss faster |
| Mastodon | Cold | 10m 41s | 8m 49s | 17% faster | 28.83 GB (93.74%) | layer miss, run total faster |
| PostHog | Cold | 29m 45s | 14m 24s | 52% faster | 19.18 GB (63.73%) | mixed: warm slower; layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 19s | 10m 20s | near tie | 49.45 MB (6.06%) | warm, run total slower |
| Spring AI | Cold | 4m 44s | 4m 27s | 6% faster | 3.60 MB (0.36%) | warm slower |
| gRPC | Cold | 32m 6s | 38m 5s | 19% slower | 362.66 MB (100.0%) | warm, run total slower |
| Zed | Run Total | 54m 13s | 52m 5s | 4% faster | 2.08 GB (74.97%) | warm slower |
| n8n | Cold | 5m 19s | 7m 17s | 37% slower | 16.81 MB more (-2.58%) | warm, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 4m 22s | 3m 33s | 19% faster | 13.97 GB (91.65%) | run total faster |
| Immich | Cold | 3m 22s | 4m 39s | 38% slower | 25.63 GB (85.45%) | run total slower |
| Mastodon | Cold | 2m 11s | 3m 8s | 44% slower | 28.48 GB (92.47%) | run total slower |
| PostHog | Cold | 15m 3s | 15m 29s | near tie | 12.65 GB (41.78%) | run total slower |
| OpenTelemetry Java | Cold | 0m 39s | 10m 27s | 1508% slower | 939.18 MB (55.05%) | run total slower |
| Spring AI | Cold | 0m 24s | 4m 19s | 979% slower | 1003.84 MB (50.44%) | run total slower |
| gRPC | Cold | 0m 28s | 0m 41s | 46% slower | 115.25 MB (10.3%) | run total slower |
| Zed | Cold | 32m 28s | 39m 11s | 21% slower | 7.50 GB (91.54%) | run total slower |
| n8n | Cold | 2m 33s | 2m 10s | 15% faster | 962.46 MB (59.09%) | run total faster |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
