## Latest Benchmark Report

Generated: 2026-04-25 16:49 UTC

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
| PostHog | Run Total | 26m 2s | 16m 2s | 38% faster | 6.56 GB (52.68%) | cold faster |
| OpenTelemetry Java | Cold | 9m 21s | 10m 49s | 16% slower | 49.36 MB (6.05%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 31s | 4m 20s | 4% faster | 3.52 MB (0.36%) | mixed: warm slower; run total faster; 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Cold | 49m 31s | 49m 47s | near tie | 2.09 GB (75.28%) | warm slower; 2 paired samples |
| n8n | Cold | 5m 20s | 6m 3s | 13% slower | 16.52 MB more (-2.5%) | warm, run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 1m 7s | 1m 4s | reseeded 2/3 | 9.63 GB (96.73%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | Cold | 0m 12s | 0m 18s | 46% slower | 7.62 GB (77.06%) | run total slower; tiny run; setup dominates; 3 paired samples |
| Mastodon | First Build | 0m 18s | 6m 39s | reseeded 2/3 | 9.19 GB (90.06%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 12m 29s | 11m 35s | reseeded 3/3 | 3.82 GB (39.29%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 7s | 11m 6s | 890% slower | 1.03 GB (57.9%) | run total slower; 3 paired samples |
| Spring AI | Cold | 0m 36s | 0m 56s | 55% slower | 2.22 GB (70.23%) | run total slower; 3 paired samples |
| gRPC | Cold | 33m 5s | 33m 47s | near tie | 581.80 MB more (-179.04%) | BC used more storage; 3 paired samples |
| Zed | Cold | 22m 29s | 40m 15s | 79% slower | 7.33 GB (91.43%) | run total slower; 3 paired samples |
| n8n | Cold | 3m 58s | 4m 20s | 9% slower | 4.18 GB (86.34%) | run total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Rolling Docker rows marked reseeded are first-build investigation samples, not steady-state parity claims.
