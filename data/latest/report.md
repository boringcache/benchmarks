## Latest Benchmark Report

Generated: 2026-05-02 20:47 UTC

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
| Immich | Cold | 5m 54s | 5m 9s | 13% faster | 8.15 GB (78.22%) | run total faster; 3 paired samples |
| Mastodon | Cold | 10m 54s | 9m 28s | 13% faster | 9.82 GB (90.66%) | run total faster; 3 paired samples |
| PostHog | Cold | 18m 41s | 15m 13s | 19% faster | 5.81 GB (48.9%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 10m 13s | 10m 48s | 6% slower | 50.44 MB (6.11%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 48s | 4m 21s | 9% faster | 165.87 MB more (-17.12%) | mixed: warm slower; run total faster; BC used more storage; 3 paired samples |
| gRPC | Cold | 28m 32s | 35m 38s | 25% slower | 638.97 MB more (-238.93%) | warm, run total slower; BC used more storage; 3 paired samples |
| Zed | Cold | 50m 3s | 49m 37s | near tie | 1.42 GB (51.08%) | warm slower; 3 paired samples |
| n8n | Warm | 1m 32s | 1m 9s | 25% faster | 16.60 MB more (-2.41%) | cold, run total faster; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 10s | 3m 16s | reseeded 3/3 | 9.04 GB (96.46%) | 3 paired samples; BC reseeded 3/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 4m 59s | 5m 9s | reseeded 3/3 | 7.75 GB (77.36%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 14m 53s | 11m 9s | reseeded 3/3 | 4.93 GB (45.87%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 31s | 4m 12s | 177% slower | 1.89 GB (71.45%) | run total slower; 3 paired samples |
| Spring AI | Cold | 0m 46s | 0m 49s | near tie | 1.82 GB (56.94%) | run total slower; 3 paired samples |
| gRPC | Cold | 24m 43s | 35m 45s | 45% slower | 337.29 MB more (-59.38%) | run total slower; BC used more storage; 3 paired samples |
| Zed | Cold | 24m 40s | 29m 22s | 19% slower | 6.26 GB (81.83%) | run total slower; 3 paired samples |
| n8n | Cold | 3m 18s | 3m 48s | 15% slower | 6.79 GB (90.8%) | run total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
