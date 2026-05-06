## Latest Benchmark Report

Generated: 2026-05-06 11:08 UTC

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
| Hugo | Cold | 3m 29s | 3m 30s | near tie | 5.97 GB (94.73%) | run total slower; 3 paired samples |
| Immich | Cold | 5m 48s | 4m 58s | 14% faster | 8.01 GB (77.93%) | run total faster; 3 paired samples |
| Mastodon | Cold | 10m 54s | 9m 28s | 13% faster | 9.82 GB (90.66%) | run total faster; 3 paired samples |
| PostHog | Cold | 20m 3s | 15m 1s | 25% faster | 8.30 GB (57.44%) | mixed: warm slower; run total faster; 3 paired samples |
| OpenTelemetry Java | Warm | 3m 28s | 0m 56s | 73% faster | 20.41 MB (2.52%) | 3 paired samples |
| Spring AI | Warm | 0m 31s | 0m 30s | near tie | 80.75 MB more (-8.31%) | cold, run total slower; BC used more storage; 3 paired samples |
| gRPC | Cold | 35m 22s | 37m 2s | 5% slower | 489.55 MB more (-182.91%) | warm, run total slower; BC used more storage; 3 paired samples |
| Zed | Run Total | 52m 27s | 51m 39s | near tie | 53.21 MB (1.87%) | warm slower; 3 paired samples |
| n8n | Run Total | 6m 43s | 6m 11s | 8% faster | 16.59 MB more (-2.41%) | mixed: warm slower; cold faster; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 1m 10s | 1m 27s | reseeded 1/3 | 5.97 GB (94.73%) | 3 paired samples; BC reseeded 1/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 1m 19s | 3m 18s | cache import ok | 7.66 GB (77.13%) | 3 paired samples; Rolling BoringCache did not find a prior rolling-scope OCI import. This run bootstraps the next continuous-commit sample and is not comparable as a cache-hit sample. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 17m 34s | 13m 27s | cache import ok | 4.38 GB (41.94%) | 3 paired samples; Rolling BoringCache did not find a prior rolling-scope OCI import. This run bootstraps the next continuous-commit sample and is not comparable as a cache-hit sample. |
| OpenTelemetry Java | Cold | 0m 56s | 1m 25s | 52% slower | 1.96 GB (72.92%) | run total slower; 3 paired samples |
| Spring AI | Cold | 0m 41s | 0m 34s | 16% faster | 2.00 GB (62.06%) | run total faster; 3 paired samples |
| gRPC | Cold | 0m 32s | 3m 2s | 469% slower | 184.28 MB more (-26.47%) | run total slower; BC used more storage; 3 paired samples |
| Zed | Cold | 31m 24s | 35m 8s | 12% slower | 8.17 GB (71.44%) | run total slower; 3 paired samples |
| n8n | Run Total | 4m 48s | 3m 44s | 22% faster | 7.34 GB (91.42%) | cold faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.
