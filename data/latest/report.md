## Latest Benchmark Report

Generated: 2026-04-28 20:57 UTC

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
| Hugo | Cold | 3m 34s | 3m 34s | near tie | 8.91 GB (96.41%) | 3 paired samples |
| Immich | Cold | 6m 10s | 5m 4s | 18% faster | 7.45 GB (76.65%) | run total faster; 3 paired samples |
| Mastodon | Cold | 10m 20s | 9m 10s | 11% faster | 8.98 GB (89.84%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 10m 40s | 10m 39s | near tie | 49.45 MB (6.06%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 25s | 4m 38s | 5% slower | 3.15 MB (0.33%) | run total slower; 3 paired samples |
| gRPC | Warm | 36m 27s | 1m 31s | 96% faster | 743.91 MB more (-457.84%) | cold slower; BC used more storage; 2 paired samples |
| Zed | Cold | 49m 33s | 50m 9s | near tie | 2.10 GB (75.29%) | warm slower; 2 paired samples |
| n8n | Warm | 1m 8s | 1m 2s | 9% faster | 16.21 MB more (-2.43%) | run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 3m 5s | 3m 11s | reseeded 3/3 | 8.02 GB (96.03%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 4m 22s | 4m 24s | reseeded 3/3 | 8.08 GB (78.1%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 25m 17s | 10m 49s | reseeded 3/3 | 6.16 GB (51.65%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 1m 7s | 11m 6s | 890% slower | 1.03 GB (57.9%) | run total slower; 3 paired samples |
| Spring AI | Cold | 1m 34s | 2m 8s | 36% slower | 2.11 GB (66.7%) | run total slower; 3 paired samples |
| gRPC | Cold | 36m 38s | 23m 19s | 36% faster | 647.57 MB more (-199.17%) | run total faster; BC used more storage; 3 paired samples |
| Zed | Cold | 31m 5s | 32m 33s | 5% slower | 8.87 GB (92.81%) | 3 paired samples |
| n8n | Run Total | 2m 41s | 2m 5s | 22% faster | 5.64 GB (92.08%) | cold faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
