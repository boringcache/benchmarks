## Latest Benchmark Report

Generated: 2026-05-01 16:49 UTC

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
| Immich | Cold | 5m 21s | 5m 8s | 4% faster | 8.40 GB (78.74%) | run total faster; 3 paired samples |
| Mastodon | Cold | 10m 54s | 9m 28s | 13% faster | 9.82 GB (90.66%) | run total faster; 3 paired samples |
| PostHog | Cold | 22m 28s | 15m 26s | 31% faster | 6.42 GB (51.42%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 10m 30s | 10m 43s | near tie | 49.74 MB (6.02%) | warm slower; 3 paired samples |
| Spring AI | Cold | 4m 48s | 4m 21s | 9% faster | 165.87 MB more (-17.12%) | mixed: warm slower; run total faster; BC used more storage; 3 paired samples |
| gRPC | Warm | 30m 34s | 2m 22s | 92% faster | — | storage unavailable; 3 paired samples |
| Zed | Cold | 49m 14s | 50m 13s | near tie | 2.10 GB (75.32%) | run total slower; 3 paired samples |
| n8n | Warm | 1m 32s | 1m 9s | 25% faster | 16.60 MB more (-2.41%) | cold, run total faster; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 10s | 3m 16s | reseeded 3/3 | 9.04 GB (96.46%) | 3 paired samples; BC reseeded 3/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 4m 49s | 5m 54s | reseeded 3/3 | 7.69 GB (77.23%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 15m 15s | 10m 54s | reseeded 3/3 | 4.82 GB (45.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 5m 6s | 9m 28s | 85% slower | 1.86 GB (71.07%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 34s | 1m 37s | near tie | 1.88 GB (58.6%) | run total slower; 3 paired samples |
| gRPC | Cold | 33m 54s | 12m 10s | 64% faster | — | run total faster; storage unavailable; 3 paired samples |
| Zed | Cold | 24m 15s | 29m 29s | 22% slower | 6.72 GB (90.71%) | run total slower; 3 paired samples |
| n8n | Cold | 3m 18s | 3m 48s | 15% slower | 6.79 GB (90.8%) | run total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
