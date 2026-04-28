## Latest Benchmark Report

Generated: 2026-04-28 09:23 UTC

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
| Hugo | Cold | 3m 30s | 3m 28s | near tie | 9.39 GB (95.5%) | 3 paired samples |
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
| Hugo | First Build | 1m 12s | 2m 17s | reseeded 2/3 | 9.51 GB (96.63%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 11m 0s | 18m 42s | reseeded 2/3 | 7.16 GB (75.93%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 1m 28s | 4m 19s | reseeded 2/3 | 9.15 GB (90.02%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 17m 4s | 10m 53s | reseeded 3/3 | 5.74 GB (49.96%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 7s | 11m 6s | 890% slower | 1.03 GB (57.9%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 34s | 2m 20s | 48% slower | 2.16 GB (68.43%) | run total slower; 3 paired samples |
| gRPC | Cold | 34m 32s | 22m 3s | 36% faster | 581.91 MB more (-179.07%) | run total faster; BC used more storage; 3 paired samples |
| Zed | Cold | 38m 50s | 39m 51s | near tie | 6.07 GB (89.83%) | 3 paired samples |
| n8n | Cold | 3m 46s | 5m 34s | 47% slower | 5.20 GB (91.34%) | run total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
