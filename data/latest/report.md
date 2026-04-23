## Latest Benchmark Report

Generated: 2026-04-23 20:52 UTC

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
| Spring AI | Cold | 4m 31s | 4m 20s | 4% faster | 3.52 MB (0.36%) | mixed: warm slower; run total faster; 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Cold | 48m 39s | 49m 19s | near tie | 2.09 GB (75.18%) | run total slower; 3 paired samples |
| n8n | Cold | 5m 20s | 6m 23s | 20% slower | 16.72 MB more (-2.54%) | warm, run total slower; BC used more storage; 2 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 1s | 2m 25s | reseeded 2/3 | 9.54 GB (95.57%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 3m 18s | 1m 43s | reseeded 1/3 | 6.19 GB (62.09%) | 3 paired samples; BC reseeded 1/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 2m 0s | 2m 8s | reseeded 2/3 | 9.23 GB (90.09%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 18m 4s | 10m 45s | reseeded 3/3 | 4.75 GB (45.3%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 7s | 11m 6s | 890% slower | 1.03 GB (57.9%) | run total slower; 3 paired samples |
| Spring AI | Cold | 2m 0s | 2m 9s | 8% slower | 1.93 GB (63.2%) | run total slower; 3 paired samples |
| gRPC | Cold | 34m 50s | 10m 16s | 71% faster | 581.88 MB more (-178.99%) | run total faster; BC used more storage; 3 paired samples |
| Zed | Run Total | 43m 53s | 42m 50s | near tie | 8.85 GB (92.79%) | 3 paired samples |
| n8n | Run Total | 5m 5s | 4m 35s | 10% faster | 3.50 GB (84.12%) | 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Rolling Docker rows marked reseeded are first-build investigation samples, not steady-state parity claims.
