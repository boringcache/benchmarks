## Latest Benchmark Report

Generated: 2026-05-05 17:06 UTC

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
| Immich | Cold | 5m 51s | 5m 5s | 13% faster | 8.31 GB (78.55%) | run total faster; 3 paired samples |
| Mastodon | Cold | 10m 54s | 9m 28s | 13% faster | 9.82 GB (90.66%) | run total faster; 3 paired samples |
| PostHog | Cold | 22m 51s | 15m 39s | 32% faster | 5.45 GB (47.24%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 10m 51s | 10m 44s | near tie | 50.41 MB (6.11%) | warm, run total slower; 3 paired samples |
| Spring AI | Warm | 0m 31s | 0m 30s | near tie | 165.88 MB more (-17.12%) | cold, run total slower; BC used more storage; 3 paired samples |
| gRPC | Cold | 35m 25s | 34m 16s | 3% faster | 496.10 MB more (-185.37%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Cold | 50m 0s | 50m 19s | near tie | — | warm, run total slower; storage unavailable; 3 paired samples |
| n8n | Warm | 1m 35s | 1m 10s | 26% faster | 16.54 MB more (-2.4%) | cold, run total faster; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 10s | 3m 16s | reseeded 3/3 | 9.04 GB (96.46%) | 3 paired samples; BC reseeded 3/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 1m 41s | 3m 24s | reseeded 2/3 | 7.44 GB (76.61%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 15m 30s | 11m 12s | reseeded 3/3 | 4.94 GB (45.81%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 3m 19s | 4m 48s | 45% slower | 1.91 GB (71.6%) | run total slower; 3 paired samples |
| Spring AI | Cold | 2m 28s | 2m 52s | 16% slower | 1.93 GB (60.29%) | run total slower; 3 paired samples |
| gRPC | Cold | 0m 38s | 2m 22s | 270% slower | 292.30 MB more (-47.46%) | run total slower; BC used more storage; 3 paired samples |
| Zed | Cold | 24m 31s | 41m 53s | 71% slower | 2.41 GB more (-30.85%) | run total slower; BC used more storage; 3 paired samples |
| n8n | Run Total | 5m 23s | 4m 45s | 12% faster | 6.93 GB (90.97%) | cold faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
