## Latest Benchmark Report

Generated: 2026-05-04 01:18 UTC

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
| Hugo | Warm | 0m 14s | 0m 8s | 44% faster | 8.95 GB (96.42%) | cold faster; 3 paired samples |
| Immich | Cold | 6m 10s | 5m 39s | 8% faster | 7.72 GB (77.27%) | run total faster; 3 paired samples |
| Mastodon | Cold | 10m 54s | 9m 28s | 13% faster | 9.82 GB (90.66%) | run total faster; 3 paired samples |
| PostHog | Cold | 25m 24s | 14m 58s | 41% faster | 7.50 GB (55.28%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 10m 13s | 10m 48s | 6% slower | 50.44 MB (6.11%) | warm, run total slower; 3 paired samples |
| Spring AI | Warm | 0m 31s | 0m 28s | near tie | 165.88 MB more (-17.12%) | run total slower; BC used more storage; 3 paired samples |
| gRPC | Cold | 28m 32s | 35m 14s | 23% slower | 636.35 MB more (-237.95%) | warm, run total slower; BC used more storage; 3 paired samples |
| Zed | Run Total | 52m 54s | 51m 13s | 3% faster | 73.72 MB (2.58%) | warm slower; 3 paired samples |
| n8n | Warm | 1m 32s | 1m 9s | 25% faster | 16.60 MB more (-2.41%) | cold, run total faster; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 10s | 3m 16s | reseeded 3/3 | 9.04 GB (96.46%) | 3 paired samples; BC reseeded 3/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 1m 26s | 4m 25s | reseeded 3/3 | 7.58 GB (76.96%) | 3 paired samples; BC reseeded 3/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 17m 30s | 13m 12s | reseeded 3/3 | 6.12 GB (51.22%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 31s | 4m 12s | 177% slower | 1.89 GB (71.45%) | run total slower; 3 paired samples |
| Spring AI | Cold | 0m 51s | 1m 53s | 124% slower | 1.82 GB (56.95%) | run total slower; 3 paired samples |
| gRPC | Cold | 24m 43s | 35m 45s | 45% slower | 337.29 MB more (-59.38%) | run total slower; BC used more storage; 3 paired samples |
| Zed | Cold | 32m 11s | 33m 39s | 5% slower | 7.85 GB (68.43%) | 3 paired samples |
| n8n | Cold | 3m 18s | 3m 48s | 15% slower | 6.79 GB (90.8%) | run total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
