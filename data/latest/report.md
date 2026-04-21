## Latest Benchmark Report

Generated: 2026-04-21 05:18 UTC

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
| Immich | Cold | 4m 56s | 4m 21s | 12% faster | 7.42 GB (63.47%) | mixed: warm, layer miss slower; run total faster |
| Mastodon | Warm | 0m 12s | 0m 10s | near tie | 8.82 GB (81.3%) | cold, layer miss, run total faster |
| PostHog | Run Total | 19m 35s | 15m 55s | 19% faster | 517.16 MB more (-4.53%) | mixed: warm, layer miss slower; cold faster; BC used more storage |
| OpenTelemetry Java | Cold | 10m 26s | 10m 41s | near tie | 49.33 MB (6.05%) | warm, run total slower |
| Spring AI | Cold | 4m 16s | 3m 50s | 10% faster | 3.84 MB (0.4%) | warm, run total slower |
| gRPC | Warm | 36m 4s | 1m 52s | 95% faster | 740.29 MB more (-455.6%) | cold, run total faster; BC used more storage |
| Zed | Cold | 49m 31s | 47m 52s | 3% faster | 2.08 GB (75.0%) | warm slower |
| n8n | Cold | 5m 26s | 4m 49s | 11% faster | 16.63 MB more (-2.55%) | warm slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 2m 46s | 3m 3s | 10% slower | 9.11 GB (93.22%) | run total slower |
| Immich | Cold | 3m 1s | 3m 34s | 18% slower | 5.65 GB (56.95%) | run total slower |
| Mastodon | Cold | 2m 37s | 8m 42s | 232% slower | 7.86 GB (79.48%) | run total slower |
| PostHog | Cold | 12m 31s | 10m 38s | 15% faster | 1.78 GB more (-18.01%) | run total faster; BC used more storage |
| OpenTelemetry Java | Cold | 8m 22s | 11m 40s | 39% slower | 1005.19 MB (56.74%) | run total slower |
| Spring AI | Cold | 0m 32s | 4m 1s | 653% slower | 1.89 GB (66.61%) | run total slower |
| gRPC | Cold | 36m 46s | 32m 7s | 13% faster | 581.80 MB more (-179.04%) | run total faster; BC used more storage |
| Zed | Run Total | 23m 59s | 22m 45s | 5% faster | 4.93 GB (87.57%) | — |
| n8n | Cold | 4m 2s | 3m 50s | 5% faster | 1.84 GB (73.9%) | — |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
