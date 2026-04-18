## Latest Benchmark Report

Generated: 2026-04-18 01:01 UTC

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
| Hugo | Run Total | 4m 48s | 3m 40s | 24% faster | 17.51 GB (93.22%) | cold, layer miss faster |
| Immich | Cold | 17m 10s | 16m 29s | 4% faster | 27.44 GB (86.99%) | layer miss, run total faster |
| Mastodon | Cold | 10m 1s | 9m 22s | 6% faster | 28.76 GB (93.72%) | layer miss, run total faster |
| PostHog | Run Total | 18m 23s | 14m 45s | 20% faster | 38.29 GB (100.0%) | cold, layer miss faster |
| OpenTelemetry Java | Cold | 10m 42s | 10m 30s | near tie | 49.26 MB (6.04%) | warm slower |
| Spring AI | Cold | 4m 12s | 4m 31s | 8% slower | 3.59 MB (0.36%) | warm, run total slower |
| gRPC | Cold | 32m 6s | 38m 5s | 19% slower | 362.66 MB (100.0%) | warm, run total slower |
| Zed | Cold | 47m 13s | 48m 47s | 3% slower | 2.08 GB (74.98%) | run total slower |
| n8n | Cold | 5m 35s | 5m 2s | 10% faster | 16.71 MB more (-2.56%) | BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 9s | 3m 25s | 2178% slower | 15.46 GB (92.4%) | run total slower |
| Immich | Cold | 0m 13s | 8m 2s | 3608% slower | 25.47 GB (85.37%) | run total slower |
| Mastodon | Cold | 2m 51s | 4m 20s | 52% slower | 27.67 GB (92.26%) | run total slower |
| PostHog | Cold | 17m 5s | 17m 9s | near tie | 11.12 GB (37.09%) | — |
| OpenTelemetry Java | Cold | 1m 18s | 10m 24s | 700% slower | 939.20 MB (55.06%) | run total slower |
| Spring AI | Cold | 0m 24s | 4m 19s | 979% slower | 1003.84 MB (50.44%) | run total slower |
| gRPC | Cold | 12m 16s | 16m 2s | 31% slower | 171.58 MB more (-15.3%) | run total slower; BC used more storage |
| Zed | Cold | 38m 45s | 18m 7s | 53% faster | 10.79 GB (93.97%) | run total faster |
| n8n | Cold | 3m 3s | 3m 36s | 18% slower | 1.08 GB (62.46%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
