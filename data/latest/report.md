## Latest Benchmark Report

Generated: 2026-04-29 13:07 UTC

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
| OpenTelemetry Java | Cold | 10m 40s | 10m 39s | near tie | 49.45 MB (6.06%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 25s | 4m 38s | 5% slower | 3.15 MB (0.33%) | run total slower; 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Run Total | 52m 30s | 52m 20s | near tie | 2.10 GB (75.3%) | — |
| n8n | Warm | 1m 5s | 1m 4s | near tie | 16.24 MB more (-2.43%) | run total slower; BC used more storage; 2 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 0s | 3m 9s | reseeded 3/3 | 8.17 GB (96.09%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 1m 37s | 3m 26s | reseeded 2/3 | 7.45 GB (76.67%) | 3 paired samples; BC reseeded 2/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 19m 8s | 16m 19s | reseeded 3/3 | 7.83 GB (57.26%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 10s | 10m 45s | 818% slower | 1.31 GB (63.48%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 39s | 3m 34s | 116% slower | 2.11 GB (66.7%) | run total slower; 3 paired samples |
| gRPC | Cold | 33m 18s | 14m 23s | 57% faster | 582.11 MB more (-179.13%) | run total faster; BC used more storage; 3 paired samples |
| Zed | Cold | 37m 23s | 42m 21s | 13% slower | 7.88 GB (91.97%) | run total slower; 3 paired samples |
| n8n | Run Total | 5m 55s | 3m 58s | 33% faster | 5.71 GB (89.13%) | cold faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
