## Latest Benchmark Report

Generated: 2026-04-30 09:20 UTC

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
| Hugo | Cold | 3m 34s | 3m 34s | near tie | 8.91 GB (96.41%) | 3 paired samples |
| Immich | Cold | 6m 54s | 5m 5s | 26% faster | 7.78 GB (77.42%) | run total faster; 3 paired samples |
| Mastodon | Cold | 10m 20s | 9m 10s | 11% faster | 8.98 GB (89.84%) | run total faster; 3 paired samples |
| PostHog | Cold | 25m 14s | 14m 38s | 42% faster | 3.59 GB (37.41%) | mixed: warm slower; run total faster |
| OpenTelemetry Java | Cold | 11m 22s | 11m 17s | near tie | 34.93 MB (4.26%) | warm slower; 3 paired samples |
| Spring AI | Cold | 4m 25s | 4m 38s | 5% slower | 3.15 MB (0.33%) | run total slower; 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Run Total | 52m 30s | 52m 20s | near tie | 2.10 GB (75.3%) | — |
| n8n | Warm | 1m 5s | 1m 4s | near tie | 16.29 MB more (-2.42%) | run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 1s | 2m 4s | reseeded 2/3 | 9.06 GB (96.46%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 0m 14s | 1m 59s | reseeded 1/3 | 7.59 GB (76.99%) | 3 paired samples; BC reseeded 1/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 18m 36s | 14m 13s | reseeded 2/3 | 7.06 GB (55.05%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 41s | 4m 24s | 161% slower | 1.84 GB (70.46%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 43s | 3m 30s | 105% slower | 2.00 GB (63.27%) | run total slower; 3 paired samples |
| gRPC | Cold | 34m 18s | 3m 35s | 90% faster | — | run total faster; storage unavailable; 3 paired samples |
| Zed | Run Total | 27m 13s | 27m 9s | near tie | 8.80 GB (92.75%) | cold slower; 3 paired samples |
| n8n | Cold | 3m 26s | 3m 19s | 3% faster | 6.19 GB (90.0%) | run total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
