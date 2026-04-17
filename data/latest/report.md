## Latest Benchmark Report

Generated: 2026-04-17 20:47 UTC

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
| Hugo | Warm | 0m 11s | 0m 10s | near tie | 16.93 GB (93.01%) | mixed: cold, run total slower; layer miss faster |
| Immich | Cold | 16m 53s | 15m 44s | 7% faster | 31.52 GB (100.0%) | mixed: warm slower; layer miss, run total faster |
| Mastodon | Run Total | 10m 15s | 10m 0s | near tie | 28.91 GB (93.75%) | mixed: warm slower; layer miss faster |
| PostHog | Cold | 26m 48s | 13m 45s | 49% faster | 19.69 GB (64.34%) | mixed: warm slower; layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 42s | 10m 30s | near tie | 49.26 MB (6.04%) | warm slower |
| Spring AI | Cold | 4m 12s | 4m 31s | 8% slower | 3.59 MB (0.36%) | warm, run total slower |
| gRPC | Cold | 32m 6s | 38m 5s | 19% slower | 362.66 MB (100.0%) | warm, run total slower |
| Zed | Run Total | 52m 37s | 51m 39s | near tie | 2.08 GB (74.98%) | — |
| n8n | Cold | 5m 35s | 5m 2s | 10% faster | 16.71 MB more (-2.56%) | BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 9s | 3m 25s | 2178% slower | 15.46 GB (92.4%) | run total slower |
| Immich | Cold | 5m 1s | 6m 5s | 21% slower | 25.10 GB (85.19%) | run total slower |
| Mastodon | Cold | 2m 51s | 4m 20s | 52% slower | 27.67 GB (92.26%) | run total slower |
| PostHog | Cold | 16m 0s | 14m 8s | 12% faster | 14.40 GB (43.29%) | run total faster |
| OpenTelemetry Java | Cold | 1m 18s | 10m 24s | 700% slower | 939.20 MB (55.06%) | run total slower |
| Spring AI | Cold | 0m 24s | 4m 19s | 979% slower | 1003.84 MB (50.44%) | run total slower |
| gRPC | Cold | 12m 16s | 16m 2s | 31% slower | 171.58 MB more (-15.3%) | run total slower; BC used more storage |
| Zed | Run Total | 37m 17s | 34m 45s | 7% faster | 10.42 GB (93.76%) | — |
| n8n | Cold | 3m 3s | 3m 36s | 18% slower | 1.08 GB (62.46%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
