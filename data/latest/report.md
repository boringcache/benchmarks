## Latest Benchmark Report

Generated: 2026-04-30 20:52 UTC

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
| Immich | Cold | 5m 26s | 6m 15s | 15% slower | 7.54 GB (76.87%) | run total slower; 3 paired samples |
| Mastodon | Cold | 10m 54s | 9m 28s | 13% faster | 9.82 GB (90.66%) | run total faster; 3 paired samples |
| PostHog | Cold | 23m 48s | 15m 2s | 37% faster | 8.05 GB (57.04%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 11m 4s | 10m 47s | near tie | 49.33 MB (5.97%) | warm slower; 3 paired samples |
| Spring AI | Cold | 4m 5s | 4m 40s | 14% slower | 165.69 MB more (-17.13%) | warm, run total slower; BC used more storage; 3 paired samples |
| gRPC | Warm | 33m 57s | 2m 8s | 94% faster | — | cold slower; storage unavailable; 3 paired samples |
| Zed | Cold | 50m 5s | 51m 28s | near tie | 2.10 GB (75.33%) | 3 paired samples |
| n8n | Cold | 5m 30s | 5m 36s | near tie | 16.56 MB more (-2.41%) | warm, run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 10s | 3m 16s | reseeded 3/3 | 9.04 GB (96.46%) | 3 paired samples; BC reseeded 3/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 4m 35s | 2m 53s | reseeded 2/3 | 7.46 GB (76.68%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 23m 53s | 12m 7s | reseeded 3/3 | 8.21 GB (58.21%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 4m 2s | 9m 27s | 134% slower | 1.83 GB (70.74%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 26s | 2m 28s | 72% slower | 1.84 GB (58.16%) | run total slower; 3 paired samples |
| gRPC | Cold | 36m 53s | 14m 9s | 62% faster | — | run total faster; storage unavailable; 3 paired samples |
| Zed | Run Total | 30m 6s | 27m 30s | 9% faster | 6.28 GB (90.14%) | 3 paired samples |
| n8n | Run Total | 5m 50s | 4m 53s | 16% faster | 6.64 GB (90.6%) | cold faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
