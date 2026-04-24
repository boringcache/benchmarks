## Latest Benchmark Report

Generated: 2026-04-24 16:51 UTC

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
| Zed | Cold | 49m 6s | 49m 51s | near tie | 2.09 GB (75.27%) | warm, run total slower; 3 paired samples |
| n8n | Cold | 5m 20s | 6m 3s | 13% slower | 16.52 MB more (-2.5%) | warm, run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 1m 5s | 3m 29s | reseeded 3/3 | 9.64 GB (96.67%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 0m 18s | 2m 44s | reseeded 1/3 | 7.60 GB (77.01%) | 3 paired samples; BC reseeded 1/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 0m 19s | 6m 28s | reseeded 2/3 | 9.23 GB (90.1%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 17m 58s | 14m 33s | reseeded 3/3 | 6.08 GB (50.78%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 7s | 11m 6s | 890% slower | 1.03 GB (57.9%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 56s | 4m 9s | 115% slower | 2.17 GB (68.46%) | run total slower; 3 paired samples |
| gRPC | Cold | 35m 23s | 35m 11s | near tie | 581.03 MB more (-178.8%) | BC used more storage; 3 paired samples |
| Zed | Cold | 42m 6s | 44m 27s | 6% slower | 5.98 GB (89.68%) | run total slower; 3 paired samples |
| n8n | Cold | 4m 7s | 5m 37s | 36% slower | 4.04 GB (85.91%) | run total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Rolling Docker rows marked reseeded are first-build investigation samples, not steady-state parity claims.
