## Latest Benchmark Report

Generated: 2026-04-27 20:52 UTC

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
| OpenTelemetry Java | Cold | 10m 6s | 10m 45s | 6% slower | 49.40 MB (6.05%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 25s | 4m 38s | 5% slower | 3.15 MB (0.33%) | run total slower; 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Cold | 49m 33s | 50m 9s | near tie | 2.10 GB (75.29%) | warm slower; 2 paired samples |
| n8n | Warm | 1m 8s | 1m 2s | 9% faster | 16.21 MB more (-2.43%) | run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 1m 12s | 2m 17s | reseeded 2/3 | 9.51 GB (96.63%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 1m 6s | 1m 19s | reseeded 1/3 | 7.47 GB (76.71%) | 3 paired samples; BC reseeded 1/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 1m 28s | 4m 19s | reseeded 2/3 | 9.15 GB (90.02%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 20m 28s | 11m 35s | reseeded 3/3 | 5.85 GB (50.44%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 7s | 11m 6s | 890% slower | 1.03 GB (57.9%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 34s | 2m 20s | 48% slower | 2.16 GB (68.43%) | run total slower; 3 paired samples |
| gRPC | Cold | 36m 28s | 30m 39s | 16% faster | 581.80 MB more (-179.04%) | run total faster; BC used more storage; 3 paired samples |
| Zed | Run Total | 31m 0s | 30m 18s | near tie | 8.08 GB (92.16%) | cold slower; 3 paired samples |
| n8n | Cold | 3m 1s | 2m 47s | 8% faster | 4.88 GB (86.9%) | 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
