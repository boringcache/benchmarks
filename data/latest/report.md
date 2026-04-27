## Latest Benchmark Report

Generated: 2026-04-27 17:02 UTC

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
| Immich | Cold | 6m 26s | 4m 58s | 23% faster | 7.17 GB (70.32%) | run total faster; 3 paired samples |
| Mastodon | Cold | 10m 15s | 9m 12s | 10% faster | 8.89 GB (84.01%) | mixed: warm slower; run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 9m 21s | 10m 49s | 16% slower | 49.36 MB (6.05%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 28s | 4m 22s | near tie | 3.31 MB (0.34%) | 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Cold | 49m 58s | 49m 55s | near tie | 2.09 GB (75.28%) | warm slower |
| n8n | Cold | 5m 22s | 5m 52s | 9% slower | 16.20 MB more (-2.45%) | warm, run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 1m 26s | 1m 4s | reseeded 1/3 | 9.41 GB (96.59%) | 3 paired samples; BC reseeded 1/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | Cold | 0m 12s | 0m 18s | 46% slower | 7.62 GB (77.06%) | run total slower; tiny run; setup dominates; 3 paired samples |
| Mastodon | First Build | 1m 28s | 4m 19s | reseeded 2/3 | 9.15 GB (90.02%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 20m 2s | 14m 0s | reseeded 3/3 | 5.83 GB (50.49%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 7s | 11m 6s | 890% slower | 1.03 GB (57.9%) | run total slower; 3 paired samples |
| Spring AI | Cold | 0m 36s | 0m 56s | 55% slower | 2.22 GB (70.23%) | run total slower; 3 paired samples |
| gRPC | Cold | 36m 43s | 31m 43s | 14% faster | 581.80 MB more (-179.04%) | run total faster; BC used more storage; 3 paired samples |
| Zed | Run Total | 31m 0s | 30m 18s | near tie | 8.08 GB (92.16%) | cold slower; 3 paired samples |
| n8n | Cold | 3m 45s | 4m 22s | 16% slower | 4.43 GB (87.03%) | 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
