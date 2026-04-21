## Latest Benchmark Report

Generated: 2026-04-21 20:48 UTC

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
| Hugo | Run Total | 4m 7s | 3m 18s | 20% faster | 9.32 GB (93.36%) | mixed: warm slower; cold, layer miss faster |
| Immich | Cold | 5m 58s | 4m 42s | 21% faster | 6.37 GB (58.58%) | mixed: warm, layer miss slower; run total faster |
| Mastodon | Cold | 9m 40s | 9m 14s | 4% faster | 10.86 GB (100.0%) | mixed: warm slower; layer miss, run total faster |
| PostHog | Run Total | 19m 42s | 15m 51s | 20% faster | 11.46 GB (100.0%) | mixed: warm slower; cold, layer miss faster |
| OpenTelemetry Java | Cold | 10m 55s | 8m 21s | 24% faster | 49.28 MB (6.04%) | mixed: warm slower; run total faster |
| Spring AI | Warm | 0m 34s | 0m 33s | near tie | 3.48 MB (0.36%) | run total slower |
| gRPC | Warm | 36m 51s | 1m 12s | 97% faster | 744.28 MB more (-458.07%) | cold, run total slower; BC used more storage |
| Zed | Cold | 48m 38s | 49m 46s | near tie | 2.77 GB (100.0%) | warm slower |
| n8n | Cold | 5m 25s | 5m 29s | near tie | 16.79 MB more (-2.55%) | warm slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 9s | 3m 13s | 2044% slower | 9.07 GB (93.19%) | run total slower |
| Immich | Cold | 7m 8s | 4m 34s | 36% faster | 6.37 GB (58.58%) | run total faster |
| Mastodon | Cold | 0m 11s | 8m 34s | 4573% slower | 7.96 GB (79.68%) | run total slower |
| PostHog | Cold | 29m 4s | 14m 15s | 51% faster | 439.27 MB more (-3.82%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 0m 52s | 11m 46s | 1258% slower | 1.02 GB (57.73%) | run total slower |
| Spring AI | Run Total | 1m 6s | 0m 52s | 21% faster | 2.00 GB (67.88%) | — |
| gRPC | Cold | 27m 56s | 36m 45s | 32% slower | 581.80 MB more (-179.04%) | run total slower; BC used more storage |
| Zed | Cold | 49m 12s | 53m 21s | 8% slower | 4.85 GB (87.49%) | run total slower |
| n8n | Cold | 1m 16s | 5m 28s | 332% slower | 2.29 GB (77.66%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
