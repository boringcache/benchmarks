## Latest Benchmark Report

Generated: 2026-04-29 17:07 UTC

### Lane Coverage

| Benchmark | Fresh | Rolling |
| --- | --- | --- |
| Hugo | yes | yes |
| Immich | yes | yes |
| Mastodon | yes | yes |
| PostHog | — | yes |
| OpenTelemetry Java | yes | yes |
| Spring AI | yes | yes |
| gRPC | yes | yes |
| Zed | yes | yes |
| n8n | yes | yes |

### Fresh Isolated

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 34s | 3m 34s | near tie | 8.91 GB (96.41%) | 3 paired samples |
| Immich | Cold | 6m 54s | 5m 5s | 26% faster | 7.78 GB (77.42%) | run total faster; 3 paired samples |
| Mastodon | Cold | 10m 20s | 9m 10s | 11% faster | 8.98 GB (89.84%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 11m 22s | 11m 17s | near tie | 34.93 MB (4.26%) | warm slower; 3 paired samples |
| Spring AI | Cold | 4m 25s | 4m 38s | 5% slower | 3.15 MB (0.33%) | run total slower; 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Run Total | 52m 30s | 52m 20s | near tie | 2.10 GB (75.3%) | — |
| n8n | Warm | 1m 5s | 1m 4s | near tie | 16.24 MB more (-2.43%) | run total slower; BC used more storage; 2 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 59s | 2m 57s | reseeded 3/3 | 8.98 GB (96.44%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 1m 41s | 2m 55s | reseeded 2/3 | 7.44 GB (76.65%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 15m 29s | 11m 47s | reseeded 2/3 | 6.58 GB (52.95%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 0m 57s | 10m 55s | 1049% slower | 1.57 GB (67.06%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 49s | 4m 45s | 161% slower | 2.05 GB (64.96%) | run total slower; 3 paired samples |
| gRPC | Cold | 33m 18s | 14m 23s | 57% faster | 582.11 MB more (-179.13%) | run total faster; BC used more storage; 3 paired samples |
| Zed | Run Total | 35m 38s | 34m 27s | 3% faster | 10.76 GB (94.0%) | 3 paired samples |
| n8n | Run Total | 6m 5s | 4m 29s | 26% faster | 6.01 GB (89.57%) | cold faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
