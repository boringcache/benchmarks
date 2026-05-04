## Latest Benchmark Report

Generated: 2026-05-04 09:21 UTC

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
| Immich | Cold | 5m 47s | 5m 40s | near tie | 8.06 GB (78.04%) | 3 paired samples |
| Mastodon | Cold | 10m 54s | 9m 28s | 13% faster | 9.82 GB (90.66%) | run total faster; 3 paired samples |
| PostHog | Cold | 22m 12s | 15m 8s | 32% faster | 5.70 GB (48.43%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 10m 13s | 10m 48s | 6% slower | 50.44 MB (6.11%) | warm, run total slower; 3 paired samples |
| Spring AI | Warm | 0m 31s | 0m 30s | near tie | 165.88 MB more (-17.12%) | cold, run total slower; BC used more storage; 3 paired samples |
| gRPC | Cold | 31m 5s | 34m 2s | 9% slower | 591.69 MB more (-221.14%) | warm, run total slower; BC used more storage; 3 paired samples |
| Zed | Cold | 50m 4s | 49m 21s | near tie | 74.15 MB (2.6%) | warm slower; 3 paired samples |
| n8n | Warm | 1m 32s | 1m 9s | 25% faster | 16.60 MB more (-2.41%) | cold, run total faster; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 10s | 3m 16s | reseeded 3/3 | 9.04 GB (96.46%) | 3 paired samples; BC reseeded 3/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 0m 12s | 3m 26s | reseeded 2/3 | 7.41 GB (76.56%) | 3 paired samples; BC reseeded 2/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 14m 44s | 10m 45s | reseeded 3/3 | 5.50 GB (48.58%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 31s | 4m 12s | 177% slower | 1.89 GB (71.45%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 44s | 3m 5s | 78% slower | 2.04 GB (63.73%) | run total slower; 3 paired samples |
| gRPC | Cold | 0m 40s | 11m 36s | 1625% slower | 304.37 MB more (-50.49%) | run total slower; BC used more storage; 3 paired samples |
| Zed | Cold | 35m 52s | 37m 9s | 4% slower | 6.81 GB (59.4%) | 3 paired samples |
| n8n | Cold | 3m 18s | 3m 48s | 15% slower | 6.79 GB (90.8%) | run total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
