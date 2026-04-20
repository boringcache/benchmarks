## Latest Benchmark Report

Generated: 2026-04-20 12:53 UTC

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
| Hugo | Cold | 4m 35s | 7m 53s | 72% slower | 22.89 GB (94.74%) | run total slower |
| Immich | Warm | 0m 8s | 0m 7s | near tie | 27.23 GB (86.9%) | cold, layer miss, run total faster |
| Mastodon | Cold | 10m 2s | 13m 11s | 31% slower | 28.85 GB (93.74%) | run total slower |
| PostHog | Cold | 16m 10s | 14m 7s | 13% faster | 1.22 GB (10.06%) | layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 55s | 10m 35s | 3% faster | 49.28 MB (6.04%) | warm slower |
| Spring AI | Cold | 4m 36s | 4m 42s | near tie | 3.80 MB (0.39%) | — |
| gRPC | Warm | 27m 12s | 1m 17s | 95% faster | 744.28 MB more (-458.06%) | cold, run total slower; BC used more storage |
| Zed | Warm | 19m 58s | 18m 19s | 8% faster | 2.08 GB (74.98%) | — |
| n8n | Warm | 1m 18s | 1m 11s | 9% faster | 16.69 MB more (-2.56%) | run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 11s | 7m 58s | 4245% slower | 22.89 GB (94.74%) | run total slower |
| Immich | Cold | 0m 21s | 19m 48s | 5557% slower | 25.62 GB (86.19%) | run total slower |
| Mastodon | Cold | 0m 20s | 13m 56s | 4080% slower | 28.85 GB (93.74%) | run total slower |
| PostHog | Cold | 10m 51s | 25m 54s | 139% slower | 9.76 GB more (-97.81%) | run total slower; BC used more storage |
| OpenTelemetry Java | Cold | 0m 41s | 1m 0s | 46% slower | 960.84 MB (55.55%) | run total slower |
| Spring AI | Cold | 3m 21s | 4m 3s | 21% slower | 1.60 GB (62.9%) | run total slower |
| gRPC | Cold | 28m 8s | 37m 34s | 34% slower | 581.80 MB more (-179.04%) | run total slower; BC used more storage |
| Zed | Run Total | 23m 49s | 23m 40s | near tie | 4.78 GB (87.24%) | cold slower |
| n8n | Cold | 3m 21s | 3m 37s | 8% slower | 1.40 GB (68.27%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
