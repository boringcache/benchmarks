## Latest Benchmark Report

Generated: 2026-04-30 15:03 UTC

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
| Hugo | Warm | 0m 14s | 0m 9s | near tie | 8.97 GB (96.43%) | cold faster; 3 paired samples |
| Immich | Cold | 5m 26s | 6m 15s | 15% slower | 7.54 GB (76.87%) | run total slower; 3 paired samples |
| Mastodon | Cold | 10m 54s | 9m 28s | 13% faster | 9.82 GB (90.66%) | run total faster; 3 paired samples |
| PostHog | Warm | 1m 25s | 0m 14s | 83% faster | 8.85 GB (59.41%) | cold, run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 11m 12s | 11m 0s | near tie | 49.43 MB (5.99%) | warm slower; 3 paired samples |
| Spring AI | Cold | 4m 9s | 4m 36s | 11% slower | 165.64 MB more (-17.13%) | warm, run total slower; BC used more storage; 3 paired samples |
| gRPC | Warm | 36m 10s | 4m 10s | 88% faster | — | cold, run total faster; storage unavailable; 3 paired samples |
| Zed | Run Total | 52m 51s | 50m 55s | 4% faster | 2.10 GB (75.33%) | warm slower; 3 paired samples |
| n8n | Cold | 5m 21s | 5m 20s | near tie | 16.52 MB more (-2.4%) | warm slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 1s | 3m 7s | reseeded 3/3 | 9.06 GB (96.46%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 4m 35s | 2m 53s | reseeded 2/3 | 7.46 GB (76.68%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 23m 31s | 12m 46s | reseeded 3/3 | 6.34 GB (51.88%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 41s | 7m 27s | 344% slower | 1.85 GB (70.88%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 1s | 3m 25s | 236% slower | 2.00 GB (63.32%) | run total slower; 3 paired samples |
| gRPC | Cold | 34m 18s | 3m 2s | 91% faster | — | run total faster; storage unavailable; 3 paired samples |
| Zed | Cold | 19m 41s | 31m 48s | 62% slower | 4.99 GB (87.9%) | run total slower; 3 paired samples |
| n8n | Run Total | 5m 19s | 4m 11s | 21% faster | 6.47 GB (90.39%) | cold faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
