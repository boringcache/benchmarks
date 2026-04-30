## Latest Benchmark Report

Generated: 2026-04-30 19:18 UTC

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
| PostHog | Cold | 22m 41s | 19m 42s | 13% faster | 6.02 GB (49.85%) | mixed: warm slower; run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 11m 4s | 10m 47s | near tie | 49.33 MB (5.97%) | warm slower; 3 paired samples |
| Spring AI | Cold | 4m 5s | 4m 40s | 14% slower | 165.69 MB more (-17.13%) | warm, run total slower; BC used more storage; 3 paired samples |
| gRPC | Warm | 34m 0s | 2m 10s | 94% faster | — | run total faster; storage unavailable; 3 paired samples |
| Zed | Cold | 50m 5s | 51m 28s | near tie | 2.10 GB (75.33%) | 3 paired samples |
| n8n | Cold | 5m 34s | 5m 38s | near tie | 16.49 MB more (-2.4%) | warm, run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 1s | 3m 7s | reseeded 3/3 | 9.06 GB (96.46%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 4m 35s | 2m 53s | reseeded 2/3 | 7.46 GB (76.68%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 17m 19s | 12m 41s | reseeded 2/3 | 6.98 GB (54.23%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 4m 2s | 9m 27s | 134% slower | 1.83 GB (70.74%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 26s | 2m 28s | 72% slower | 1.84 GB (58.16%) | run total slower; 3 paired samples |
| gRPC | Cold | 34m 6s | 14m 12s | 58% faster | — | run total faster; storage unavailable; 3 paired samples |
| Zed | Run Total | 30m 6s | 27m 30s | 9% faster | 6.28 GB (90.14%) | 3 paired samples |
| n8n | Run Total | 5m 31s | 4m 45s | 14% faster | 6.59 GB (90.55%) | cold faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
