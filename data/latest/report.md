## Latest Benchmark Report

Generated: 2026-04-30 14:30 UTC

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
| n8n | Cold | 5m 20s | 5m 31s | 3% slower | 16.57 MB more (-2.44%) | run total slower; BC used more storage; 2 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 1s | 3m 10s | reseeded 3/3 | 8.67 GB (96.31%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 4m 35s | 4m 29s | reseeded 3/3 | 7.47 GB (76.72%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 23m 31s | 12m 46s | reseeded 3/3 | 6.34 GB (51.88%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 0s | 7m 37s | 662% slower | 1.84 GB (70.44%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 55s | 3m 46s | 97% slower | 2.00 GB (63.25%) | run total slower; 3 paired samples |
| gRPC | Cold | 35m 23s | 15m 23s | 57% faster | — | run total faster; storage unavailable; 3 paired samples |
| Zed | Cold | 19m 41s | 31m 48s | 62% slower | 4.99 GB (87.9%) | run total slower; 3 paired samples |
| n8n | Run Total | 5m 10s | 4m 1s | 22% faster | 6.41 GB (90.31%) | cold faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
