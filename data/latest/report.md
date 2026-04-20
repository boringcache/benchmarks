## Latest Benchmark Report

Generated: 2026-04-20 20:47 UTC

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
| Hugo | Run Total | 4m 0s | 3m 19s | 17% faster | 9.45 GB (93.44%) | cold faster |
| Immich | Cold | 5m 9s | 4m 28s | 13% faster | 5.72 GB (57.27%) | mixed: warm, layer miss slower; run total faster |
| Mastodon | Warm | 0m 12s | 0m 10s | near tie | 8.82 GB (81.3%) | cold, layer miss, run total faster |
| PostHog | Cold | 17m 32s | 13m 47s | 21% faster | 1.71 GB more (-17.23%) | mixed: warm slower; run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 10m 26s | 10m 41s | near tie | 49.33 MB (6.05%) | warm, run total slower |
| Spring AI | Cold | 4m 8s | 4m 51s | 17% slower | 3.80 MB (0.39%) | warm, run total slower |
| gRPC | Warm | 36m 4s | 1m 52s | 95% faster | 740.29 MB more (-455.6%) | cold, run total faster; BC used more storage |
| Zed | Cold | 50m 46s | 51m 20s | near tie | 2.08 GB (74.99%) | warm slower |
| n8n | Warm | 2m 59s | 1m 2s | 65% faster | 16.72 MB more (-2.56%) | run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 2m 46s | 3m 3s | 10% slower | 9.11 GB (93.22%) | run total slower |
| Immich | Cold | 0m 18s | 0m 11s | 39% faster | 6.35 GB (59.82%) | run total faster; tiny run; setup dominates |
| Mastodon | Cold | 2m 37s | 8m 42s | 232% slower | 7.86 GB (79.48%) | run total slower |
| PostHog | Cold | 15m 49s | 15m 4s | 5% faster | 1.28 GB more (-12.82%) | run total slower; BC used more storage |
| OpenTelemetry Java | Cold | 8m 22s | 11m 40s | 39% slower | 1005.19 MB (56.74%) | run total slower |
| Spring AI | Cold | 0m 39s | 1m 24s | 115% slower | 1.89 GB (66.6%) | run total slower |
| gRPC | Cold | 31m 14s | 37m 53s | 21% slower | 439.35 MB more (-90.13%) | run total slower; BC used more storage |
| Zed | Run Total | 39m 44s | 39m 8s | near tie | 10.75 GB (93.89%) | — |
| n8n | Cold | 2m 29s | 2m 27s | near tie | 1.81 GB (73.56%) | — |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
