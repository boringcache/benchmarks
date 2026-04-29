## Latest Benchmark Report

Generated: 2026-04-29 01:18 UTC

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
| Zed | Cold | 49m 33s | 50m 9s | near tie | 2.10 GB (75.29%) | warm slower; 2 paired samples |
| n8n | Warm | 1m 8s | 1m 2s | 9% faster | 16.21 MB more (-2.43%) | run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 6s | 2m 13s | reseeded 2/3 | 7.59 GB (95.81%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 1m 21s | 2m 41s | reseeded 2/3 | 7.52 GB (76.85%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 14m 31s | 10m 55s | reseeded 3/3 | 4.81 GB (45.12%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 4m 36s | 10m 41s | 132% slower | 1.03 GB (53.67%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 34s | 2m 9s | 36% slower | 2.06 GB (65.01%) | run total slower; 3 paired samples |
| gRPC | Cold | 34m 47s | 23m 31s | 32% faster | 647.61 MB more (-199.21%) | run total faster; BC used more storage; 3 paired samples |
| Zed | Cold | 19m 11s | 20m 12s | 5% slower | 10.79 GB (94.01%) | 3 paired samples |
| n8n | Run Total | 3m 10s | 2m 6s | 34% faster | 5.85 GB (95.54%) | cold faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
