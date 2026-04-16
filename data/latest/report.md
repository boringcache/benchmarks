## Latest Benchmark Report

Generated: 2026-04-16 12:53 UTC

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
| Hugo | Cold | 3m 52s | 3m 56s | near tie | 11.31 GB (89.88%) | mixed: warm, run total slower; layer miss faster |
| Immich | Run Total | 21m 17s | 16m 5s | 24% faster | 25.88 GB (86.29%) | cold, layer miss faster |
| Mastodon | Cold | 9m 51s | 9m 38s | near tie | 21.05 GB (91.62%) | layer miss faster |
| PostHog | Run Total | 18m 22s | 14m 33s | 21% faster | 21.54 GB (65.62%) | mixed: warm slower; cold, layer miss faster |
| OpenTelemetry Java | Cold | 10m 22s | 10m 58s | 6% slower | 49.38 MB (6.05%) | warm, run total slower |
| Spring AI | Cold | 3m 35s | 4m 39s | 30% slower | 4.39 MB (0.44%) | run total slower |
| gRPC | Cold | 36m 49s | 25m 26s | 31% faster | 362.53 MB (100.0%) | mixed: warm slower; run total faster |
| Zed | Cold | 48m 15s | 53m 35s | 11% slower | 2.07 GB (74.97%) | warm, run total slower |
| n8n | Warm | 0m 48s | 0m 45s | near tie | 16.77 MB more (-2.57%) | cold, run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 37s | 3m 50s | 6% slower | 11.31 GB (89.88%) | mixed: run total slower; layer miss faster |
| Immich | Run Total | 13m 13s | 7m 37s | 42% faster | 25.52 GB (85.35%) | mixed: cold slower; layer miss faster |
| Mastodon | Run Total | 8m 38s | 3m 36s | 58% faster | 19.78 GB (89.4%) | mixed: cold slower; layer miss faster |
| PostHog | Cold | 15m 18s | 8m 23s | 45% faster | 13.76 GB (45.39%) | run total faster |
| OpenTelemetry Java | Cold | 10m 44s | 8m 41s | 19% faster | 49.22 MB (6.03%) | run total faster |
| Spring AI | Cold | 0m 22s | 0m 19s | near tie | 994.44 MB (50.22%) | run total slower |
| gRPC | Cold | 12m 54s | 21m 30s | 67% slower | 723.45 MB (100.0%) | warm, run total slower |
| Zed | Cold | 49m 35s | 34m 6s | 31% faster | 4.84 GB (87.49%) | mixed: warm slower; run total faster |
| n8n | Cold | 1m 48s | 1m 36s | 11% faster | 697.59 MB (51.14%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
