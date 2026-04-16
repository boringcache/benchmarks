## Latest Benchmark Report

Generated: 2026-04-16 01:09 UTC

### Lane Coverage

| Benchmark | Fresh | Rolling |
| --- | --- | --- |
| Hugo | yes | yes |
| Immich | yes | yes |
| Mastodon | yes | yes |
| PostHog | yes | yes |
| OpenTelemetry Java | yes | — |
| Spring AI | yes | yes |
| gRPC | yes | yes |
| Zed | yes | yes |
| n8n | yes | yes |

### Fresh Isolated

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Warm | 0m 3s | 0m 2s | near tie | 8.65 GB (87.17%) | cold, layer miss, run total faster |
| Immich | Warm | 0m 4s | 0m 2s | near tie | 27.59 GB (87.01%) | cold, layer miss, run total faster |
| Mastodon | Run Total | 11m 29s | 9m 25s | 18% faster | 13.27 GB (87.33%) | cold, layer miss faster |
| PostHog | Run Total | 17m 46s | 15m 5s | 15% faster | 23.21 GB (67.27%) | mixed: warm slower; cold, layer miss faster |
| OpenTelemetry Java | Cold | 10m 22s | 10m 58s | 6% slower | 49.38 MB (6.05%) | warm, run total slower |
| Spring AI | Cold | 3m 35s | 4m 39s | 30% slower | 4.39 MB (0.44%) | run total slower |
| gRPC | Cold | 36m 50s | 37m 34s | near tie | 366.14 MB (100.0%) | warm, run total slower |
| Zed | Cold | 47m 47s | 48m 19s | near tie | 2.56 GB (92.64%) | — |
| n8n | Cold | 8m 7s | 5m 14s | 36% faster | 16.70 MB more (-2.56%) | run total faster; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Run Total | 2m 48s | 1m 28s | 48% faster | 10.36 GB (89.06%) | mixed: cold, warm slower; layer miss faster |
| Immich | Run Total | 12m 29s | 6m 20s | 49% faster | 25.60 GB (85.38%) | mixed: cold slower; layer miss faster |
| Mastodon | Run Total | 8m 36s | 3m 48s | 56% faster | 14.58 GB (86.27%) | mixed: cold slower; layer miss faster |
| PostHog | Cold | 4m 6s | 14m 47s | 261% slower | 13.70 GB (45.93%) | mixed: run total slower; layer miss faster |
| OpenTelemetry Java | — | — | — | — | — | not published yet |
| Spring AI | Cold | 0m 22s | 0m 19s | near tie | 994.44 MB (50.22%) | run total slower |
| gRPC | Cold | 0m 14s | 37m 14s | 15857% slower | 730.59 MB (100.0%) | warm, run total slower |
| Zed | Run Total | 36m 3s | 35m 50s | near tie | 3.87 GB (95.0%) | warm slower |
| n8n | Cold | 0m 44s | 0m 46s | near tie | 639.56 MB (48.97%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
