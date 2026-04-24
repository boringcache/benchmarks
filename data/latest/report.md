## Latest Benchmark Report

Generated: 2026-04-24 05:30 UTC

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
| Hugo | Cold | 3m 34s | 4m 46s | 33% slower | 9.22 GB (93.29%) | warm, run total slower; 3 paired samples |
| Immich | Cold | 11m 10s | 10m 17s | 8% faster | 15.65 GB (78.37%) | run total faster; 2 paired samples |
| Mastodon | Cold | 10m 7s | 10m 38s | 5% slower | 8.83 GB (81.31%) | warm, run total slower; 3 paired samples |
| PostHog | Cold | 23m 25s | 16m 31s | 30% faster | 1.04 GB more (-9.67%) | run total faster; BC used more storage; 2 paired samples |
| OpenTelemetry Java | Cold | 9m 21s | 10m 49s | 16% slower | 49.36 MB (6.05%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 43s | 4m 10s | 12% faster | 3.33 MB (0.34%) | mixed: warm slower; run total faster; 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Cold | 48m 41s | 49m 49s | near tie | 2.09 GB (75.27%) | run total slower; 2 paired samples |
| n8n | Cold | 5m 10s | 6m 3s | 17% slower | 16.55 MB more (-2.51%) | warm, run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 1s | 2m 25s | reseeded 2/3 | 9.54 GB (95.57%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 3m 18s | 1m 43s | reseeded 1/3 | 6.19 GB (62.09%) | 3 paired samples; BC reseeded 1/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 2m 0s | 2m 8s | reseeded 2/3 | 9.23 GB (90.09%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 12m 47s | 7m 9s | reseeded 2/3 | 4.52 GB (44.38%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 7s | 11m 6s | 890% slower | 1.03 GB (57.9%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 30s | 2m 49s | 88% slower | 2.08 GB (65.6%) | run total slower; 3 paired samples |
| gRPC | Cold | 35m 33s | 34m 11s | 4% faster | 581.03 MB more (-178.8%) | run total faster; BC used more storage; 3 paired samples |
| Zed | Run Total | 41m 9s | 40m 29s | near tie | 8.87 GB (92.81%) | 3 paired samples |
| n8n | Run Total | 5m 9s | 4m 50s | 6% faster | 3.45 GB (83.92%) | 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Rolling Docker rows marked reseeded are first-build investigation samples, not steady-state parity claims.
