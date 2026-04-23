## Latest Benchmark Report

Generated: 2026-04-23 13:51 UTC

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
| Mastodon | Cold | 10m 1s | 10m 43s | 7% slower | 15.18 GB (88.38%) | warm, run total slower; 3 paired samples |
| PostHog | Cold | 22m 45s | 17m 38s | 23% faster | 1.34 GB more (-12.86%) | mixed: warm slower; run total faster; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold | 9m 21s | 10m 49s | 16% slower | 49.36 MB (6.05%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 31s | 4m 20s | 4% faster | 3.52 MB (0.36%) | mixed: warm slower; run total faster; 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Cold | 48m 39s | 49m 19s | near tie | 2.09 GB (75.18%) | run total slower; 3 paired samples |
| n8n | Cold | 5m 20s | 6m 23s | 20% slower | 16.72 MB more (-2.54%) | warm, run total slower; BC used more storage; 2 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 2s | 2m 13s | reseeded 2/3 | 9.15 GB (93.24%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 3m 11s | 3m 9s | reseeded 2/3 | 5.37 GB (54.21%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 1m 45s | 4m 6s | reseeded 2/3 | 8.41 GB (83.26%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 14m 26s | 11m 45s | reseeded 3/3 | 777.61 MB more (-7.1%) | BC used more storage; 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 7s | 11m 6s | 890% slower | 1.03 GB (57.9%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 23s | 2m 48s | 102% slower | 2.00 GB (67.96%) | run total slower; 3 paired samples |
| gRPC | Cold | 34m 50s | 10m 16s | 71% faster | 581.88 MB more (-178.99%) | run total faster; BC used more storage; 3 paired samples |
| Zed | Run Total | 39m 9s | 38m 47s | near tie | 10.74 GB (93.99%) | 3 paired samples |
| n8n | Cold | 3m 7s | 4m 19s | 39% slower | 3.33 GB (83.44%) | run total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Rolling Docker rows marked reseeded are first-build investigation samples, not steady-state parity claims.
