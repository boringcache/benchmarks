## Latest Benchmark Report

Generated: 2026-05-06 05:41 UTC

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
| Hugo | Cold | 3m 26s | 3m 25s | near tie | 7.52 GB (95.77%) | 3 paired samples |
| Immich | Cold | 5m 47s | 5m 3s | 13% faster | 8.32 GB (78.56%) | run total faster; 3 paired samples |
| Mastodon | Cold | 10m 54s | 9m 28s | 13% faster | 9.82 GB (90.66%) | run total faster; 3 paired samples |
| PostHog | Cold | 23m 18s | 14m 30s | 38% faster | 6.86 GB (52.74%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 10m 53s | 10m 45s | near tie | 35.33 MB (4.28%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 47s | 4m 23s | 8% faster | 165.07 MB more (-16.98%) | BC used more storage; 3 paired samples |
| gRPC | Cold | 35m 25s | 34m 16s | 3% faster | 496.10 MB more (-185.37%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Cold | 46m 44s | 49m 44s | 6% slower | 52.69 MB (1.86%) | warm slower; 3 paired samples |
| n8n | Cold | 5m 18s | 5m 51s | 10% slower | 16.45 MB more (-2.39%) | warm, run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 1m 10s | 2m 29s | reseeded 2/3 | 7.61 GB (95.82%) | 3 paired samples; BC reseeded 2/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 1m 43s | 3m 18s | reseeded 1/3 | 7.43 GB (76.59%) | 3 paired samples; BC reseeded 1/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | Cold | 14m 58s | 7m 50s | 48% faster | 3.97 GB (39.55%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 3m 17s | 7m 33s | 130% slower | 1.94 GB (71.16%) | run total slower; 3 paired samples |
| Spring AI | Cold | 0m 41s | 0m 39s | near tie | 1.95 GB (60.6%) | 3 paired samples |
| gRPC | Cold | 0m 38s | 2m 22s | 270% slower | 292.30 MB more (-47.46%) | run total slower; BC used more storage; 3 paired samples |
| Zed | Cold | 26m 11s | 26m 16s | near tie | 7.90 GB (69.02%) | 3 paired samples |
| n8n | Run Total | 4m 13s | 3m 47s | 10% faster | 7.24 GB (91.31%) | cold slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
