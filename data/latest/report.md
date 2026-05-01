## Latest Benchmark Report

Generated: 2026-05-01 12:49 UTC

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
| Hugo | Warm | 0m 14s | 0m 8s | 44% faster | 8.95 GB (96.42%) | cold faster; 3 paired samples |
| Immich | Cold | 5m 25s | 5m 21s | near tie | 7.98 GB (77.88%) | 3 paired samples |
| Mastodon | Cold | 10m 54s | 9m 28s | 13% faster | 9.82 GB (90.66%) | run total faster; 3 paired samples |
| PostHog | Cold | 21m 54s | 14m 51s | 32% faster | 5.89 GB (49.24%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Run Total | 11m 29s | 11m 0s | 4% faster | 49.38 MB (5.98%) | mixed: warm slower; cold faster; 3 paired samples |
| Spring AI | Cold | 4m 49s | 4m 28s | 7% faster | 165.87 MB more (-17.12%) | mixed: warm slower; run total faster; BC used more storage; 3 paired samples |
| gRPC | Warm | 30m 34s | 2m 22s | 92% faster | — | storage unavailable; 3 paired samples |
| Zed | Cold | 49m 14s | 50m 13s | near tie | 2.10 GB (75.32%) | run total slower; 3 paired samples |
| n8n | Cold | 5m 17s | 5m 8s | near tie | 16.61 MB more (-2.41%) | BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 10s | 3m 16s | reseeded 3/3 | 9.04 GB (96.46%) | 3 paired samples; BC reseeded 3/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 5m 53s | 6m 24s | reseeded 3/3 | 7.70 GB (77.25%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 20m 44s | 16m 9s | reseeded 3/3 | 6.71 GB (53.21%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 4m 35s | 9m 34s | 109% slower | 1.84 GB (70.8%) | run total slower; 3 paired samples |
| Spring AI | Cold | 0m 48s | 2m 0s | 152% slower | 2.04 GB (63.72%) | run total slower; 3 paired samples |
| gRPC | Cold | 33m 54s | 12m 10s | 64% faster | — | run total faster; storage unavailable; 3 paired samples |
| Zed | Cold | 24m 15s | 29m 29s | 22% slower | 6.72 GB (90.71%) | run total slower; 3 paired samples |
| n8n | Cold | 3m 8s | 3m 37s | 15% slower | 6.77 GB (90.77%) | run total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
