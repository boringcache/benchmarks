## Latest Benchmark Report

Generated: 2026-04-24 12:53 UTC

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
| Hugo | Cold | 3m 27s | 3m 23s | near tie | 9.36 GB (94.42%) | 3 paired samples |
| Immich | Cold | 6m 54s | 4m 53s | 29% faster | 7.04 GB (67.41%) | run total faster; 2 paired samples |
| Mastodon | Cold | 10m 15s | 9m 12s | 10% faster | 8.89 GB (84.01%) | mixed: warm slower; run total faster; 3 paired samples |
| PostHog | Cold | 24m 46s | 16m 45s | 32% faster | 2.37 GB (21.14%) | run total faster; 2 paired samples |
| OpenTelemetry Java | Cold | 9m 31s | 10m 44s | 13% slower | 49.35 MB (6.05%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 34s | 4m 10s | 9% faster | 3.32 MB (0.34%) | mixed: warm slower; run total faster; 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Cold | 49m 6s | 49m 51s | near tie | 2.09 GB (75.27%) | warm, run total slower; 3 paired samples |
| n8n | Cold | 5m 20s | 6m 3s | 13% slower | 16.52 MB more (-2.5%) | warm, run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 1m 6s | 2m 23s | reseeded 2/3 | 9.68 GB (96.69%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 3m 18s | 1m 43s | reseeded 1/3 | 6.19 GB (62.09%) | 3 paired samples; BC reseeded 1/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 0m 59s | 6m 23s | reseeded 2/3 | 9.20 GB (90.06%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 16m 28s | 15m 1s | reseeded 3/3 | 4.18 GB (41.81%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 7s | 11m 6s | 890% slower | 1.03 GB (57.9%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 30s | 2m 49s | 88% slower | 2.08 GB (65.6%) | run total slower; 3 paired samples |
| gRPC | Cold | 35m 23s | 35m 11s | near tie | 581.03 MB more (-178.8%) | BC used more storage; 3 paired samples |
| Zed | Cold | 32m 44s | 41m 11s | 26% slower | 8.32 GB (92.36%) | run total slower; 3 paired samples |
| n8n | Cold | 3m 30s | 5m 36s | 60% slower | 3.83 GB (85.23%) | run total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Rolling Docker rows marked reseeded are first-build investigation samples, not steady-state parity claims.
