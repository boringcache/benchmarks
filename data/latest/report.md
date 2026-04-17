## Latest Benchmark Report

Generated: 2026-04-17 16:48 UTC

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
| Hugo | Cold | 4m 18s | 3m 46s | 12% faster | 15.47 GB (92.4%) | mixed: warm slower; layer miss, run total faster |
| Immich | Cold | 18m 11s | 15m 50s | 13% faster | 27.60 GB (87.06%) | mixed: warm slower; layer miss, run total faster |
| Mastodon | Cold | 10m 9s | 10m 31s | 4% slower | 28.86 GB (93.74%) | mixed: warm, run total slower; layer miss faster |
| PostHog | Cold | 22m 21s | 12m 29s | 44% faster | 18.97 GB (63.48%) | mixed: warm slower; layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 42s | 10m 30s | near tie | 49.26 MB (6.04%) | warm slower |
| Spring AI | Cold | 4m 12s | 4m 31s | 8% slower | 3.59 MB (0.36%) | warm, run total slower |
| gRPC | Cold | 32m 6s | 38m 5s | 19% slower | 362.66 MB (100.0%) | warm, run total slower |
| Zed | Cold | 48m 54s | 49m 26s | near tie | 2.08 GB (74.97%) | — |
| n8n | Cold | 5m 6s | 6m 49s | 34% slower | 16.75 MB more (-2.57%) | run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 0m 9s | 3m 25s | 2178% slower | 15.46 GB (92.4%) | run total slower |
| Immich | Cold | 0m 18s | 0m 27s | 50% slower | 25.16 GB (85.22%) | run total slower; tiny run; setup dominates |
| Mastodon | Cold | 2m 26s | 3m 15s | 34% slower | 27.63 GB (92.25%) | run total slower |
| PostHog | Cold | 10m 30s | 15m 18s | 46% slower | 12.38 GB (39.63%) | run total slower |
| OpenTelemetry Java | Cold | 1m 18s | 10m 24s | 700% slower | 939.20 MB (55.06%) | run total slower |
| Spring AI | Cold | 0m 24s | 4m 19s | 979% slower | 1003.84 MB (50.44%) | run total slower |
| gRPC | Cold | 0m 28s | 0m 41s | 46% slower | 115.25 MB (10.3%) | run total slower |
| Zed | Cold | 20m 8s | 22m 43s | 13% slower | 3.53 GB (83.6%) | run total slower |
| n8n | Cold | 3m 27s | 3m 13s | 7% faster | 1.02 GB (61.1%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.
