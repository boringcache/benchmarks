## Latest Benchmark Report

Generated: 2026-04-27 09:26 UTC

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
| Hugo | Cold | 3m 27s | 3m 23s | near tie | 9.36 GB (94.42%) | 3 paired samples |
| Immich | Cold | 6m 54s | 4m 53s | 29% faster | 7.04 GB (67.41%) | run total faster; 2 paired samples |
| Mastodon | Cold | 10m 15s | 9m 12s | 10% faster | 8.89 GB (84.01%) | mixed: warm slower; run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 9m 21s | 10m 49s | 16% slower | 49.36 MB (6.05%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 31s | 4m 20s | 4% faster | 3.52 MB (0.36%) | mixed: warm slower; run total faster; 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Cold | 49m 58s | 49m 55s | near tie | 2.09 GB (75.28%) | warm slower |
| n8n | Cold | 5m 20s | 6m 3s | 13% slower | 16.52 MB more (-2.5%) | warm, run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 14s | 2m 2s | reseeded 2/3 | 9.63 GB (96.67%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | Cold | 0m 12s | 0m 18s | 46% slower | 7.62 GB (77.06%) | run total slower; tiny run; setup dominates; 3 paired samples |
| Mastodon | First Build | 1m 28s | 4m 19s | reseeded 2/3 | 9.15 GB (90.02%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 13m 38s | 11m 41s | reseeded 3/3 | 5.75 GB (50.0%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 7s | 11m 6s | 890% slower | 1.03 GB (57.9%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 17s | 2m 6s | 63% slower | 2.22 GB (70.23%) | run total slower; 3 paired samples |
| gRPC | Cold | 36m 43s | 31m 43s | 14% faster | 581.80 MB more (-179.04%) | run total faster; BC used more storage; 3 paired samples |
| Zed | Cold | 23m 25s | 44m 47s | 91% slower | 8.42 GB (92.45%) | run total slower; 3 paired samples |
| n8n | Run Total | 5m 40s | 4m 0s | 29% faster | 4.33 GB (86.77%) | cold faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Rolling Docker rows marked reseeded are first-build investigation samples, not steady-state parity claims.
