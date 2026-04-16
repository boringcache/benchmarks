## Latest Benchmark Report

Generated: 2026-04-16 16:58 UTC

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
| Hugo | Cold | 4m 43s | 3m 3s | 35% faster | 13.02 GB (91.09%) | layer miss, run total faster |
| Immich | Cold | 16m 44s | 15m 55s | 5% faster | 27.83 GB (87.15%) | layer miss, run total faster |
| Mastodon | Run Total | 11m 49s | 10m 36s | 10% faster | 25.01 GB (92.85%) | cold, layer miss faster |
| PostHog | Run Total | 18m 22s | 14m 33s | 21% faster | 21.54 GB (65.62%) | mixed: warm slower; cold, layer miss faster |
| OpenTelemetry Java | Warm | 0m 37s | 0m 35s | near tie | 49.18 MB (6.03%) | cold faster |
| Spring AI | Cold | 5m 20s | 4m 11s | 22% faster | 4.40 MB (0.44%) | run total faster |
| gRPC | Cold | 27m 45s | 39m 40s | 43% slower | 362.35 MB (100.0%) | warm, run total slower |
| Zed | Cold | 48m 32s | 49m 13s | near tie | 2.08 GB (74.97%) | warm slower |
| n8n | Cold | 5m 16s | 5m 28s | 4% slower | 16.68 MB more (-2.55%) | warm, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Warm | 0m 3s | 0m 2s | near tie | 13.02 GB (91.09%) | mixed: cold, run total slower; layer miss faster |
| Immich | Run Total | 13m 18s | 4m 50s | 64% faster | 25.61 GB (85.42%) | mixed: cold slower; layer miss faster |
| Mastodon | Run Total | 8m 29s | 3m 20s | 61% faster | 24.93 GB (91.42%) | mixed: cold slower; layer miss faster |
| PostHog | Cold | 10m 14s | 12m 48s | 25% slower | 16.04 GB (50.26%) | run total slower |
| OpenTelemetry Java | Cold | 0m 38s | 8m 41s | 1271% slower | 864.93 MB (53.01%) | run total slower |
| Spring AI | Warm | 0m 23s | 0m 20s | near tie | 1000.00 MB (50.25%) | cold, run total slower |
| gRPC | Cold | 0m 16s | 0m 34s | 113% slower | 722.11 MB (100.0%) | warm, run total slower |
| Zed | Run Total | 40m 37s | 39m 58s | near tie | 7.75 GB (91.79%) | warm slower |
| n8n | Cold | 1m 59s | 5m 5s | 156% slower | 703.40 MB (51.35%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
