## Latest Benchmark Report

Generated: 2026-04-16 09:02 UTC

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
| Hugo | Cold | 3m 55s | 3m 49s | near tie | 9.79 GB (88.49%) | layer miss faster |
| Immich | Warm | 0m 4s | 0m 3s | near tie | 27.50 GB (86.97%) | cold, layer miss, run total faster |
| Mastodon | Run Total | 10m 35s | 9m 44s | 8% faster | 16.17 GB (89.36%) | cold, layer miss faster |
| PostHog | Cold | 22m 11s | 13m 56s | 37% faster | 21.58 GB (65.66%) | layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 22s | 10m 58s | 6% slower | 49.38 MB (6.05%) | warm, run total slower |
| Spring AI | Cold | 3m 35s | 4m 39s | 30% slower | 4.39 MB (0.44%) | run total slower |
| gRPC | Cold | 31m 54s | 32m 21s | near tie | 362.66 MB (100.0%) | warm, run total slower |
| Zed | Cold | 49m 26s | 48m 13s | near tie | 2.56 GB (92.64%) | — |
| n8n | Cold | 8m 7s | 5m 14s | 36% faster | 16.70 MB more (-2.56%) | run total faster; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Run Total | 2m 48s | 1m 28s | 48% faster | 10.36 GB (89.06%) | mixed: cold, warm slower; layer miss faster |
| Immich | Run Total | 13m 10s | 5m 58s | 55% faster | 25.27 GB (85.21%) | mixed: cold slower; layer miss faster |
| Mastodon | Cold | 2m 4s | 9m 28s | 358% slower | 14.47 GB (88.25%) | mixed: warm, run total slower; layer miss faster |
| PostHog | Run Total | 12m 45s | 11m 39s | 9% faster | 14.34 GB (46.41%) | cold, layer miss faster |
| OpenTelemetry Java | Cold | 10m 44s | 8m 41s | 19% faster | 49.22 MB (6.03%) | run total faster |
| Spring AI | Cold | 0m 22s | 0m 19s | near tie | 994.44 MB (50.22%) | run total slower |
| gRPC | Cold | 0m 14s | 0m 33s | 136% slower | 721.95 MB (100.0%) | warm, run total slower |
| Zed | Run Total | 25m 33s | 19m 45s | 23% faster | 6.40 GB (96.92%) | warm slower |
| n8n | Cold | 0m 44s | 0m 46s | near tie | 639.56 MB (48.97%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
