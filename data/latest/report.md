## Latest Benchmark Report

Generated: 2026-05-06 14:52 UTC

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

### Fresh

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 29s | 3m 30s | near tie | 5.97 GB (94.73%) | workflow total slower; 3 paired samples |
| Immich | Cold Build | 5m 50s | 5m 3s | 14% faster | 7.79 GB (77.43%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 9m 48s | 10m 14s | 4% slower | 9.80 GB (90.65%) | workflow total slower |
| PostHog | Warm Build | 1m 56s | 0m 13s | 89% faster | 6.35 GB (50.9%) | cold, workflow total faster; 3 paired samples |
| OpenTelemetry Java | Warm Build | 3m 28s | 0m 56s | 73% faster | 20.41 MB (2.52%) | 3 paired samples |
| Spring AI | Cold Build | 4m 28s | 4m 35s | near tie | 3.14 MB (0.33%) | warm, workflow total slower; 3 paired samples |
| gRPC | Cold Build | 35m 22s | 37m 2s | 5% slower | 489.55 MB more (-182.91%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 50m 21s | 49m 32s | near tie | 52.95 MB (1.87%) | warm slower; 3 paired samples |
| n8n | Cold Build | 5m 16s | 6m 6s | 16% slower | 16.55 MB more (-2.4%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 1m 10s | 1m 27s | cache bootstrap 1/3 | 5.97 GB (94.73%) | 3 paired samples; BC cache bootstrap 1/3; Rolling cache was unavailable for 1/3 BoringCache samples; those samples populated the rolling cache and are excluded from parity claims. |
| Immich | Commit Build | 5m 51s | 4m 12s | 28% faster | 7.38 GB (76.48%) | workflow total faster; 3 paired samples |
| Mastodon | Commit Build | 2m 20s | 2m 26s | cache bootstrap | 8.97 GB (89.87%) | Rolling cache was unavailable; this sample populated the rolling cache and is excluded from parity claims. |
| PostHog | Commit Build | 19m 6s | 12m 33s | 34% faster | 6.85 GB (53.5%) | workflow total faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 0m 56s | 1m 25s | 52% slower | 1.96 GB (72.92%) | workflow total slower; 3 paired samples |
| Spring AI | Workflow Total | 2m 59s | 2m 46s | 7% faster | 2.09 GB (65.02%) | commit build faster; 3 paired samples |
| gRPC | Commit Build | 0m 32s | 3m 2s | 469% slower | 184.28 MB more (-26.47%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 36m 26s | 35m 44s | near tie | 4.95 GB (51.93%) | 3 paired samples |
| n8n | Workflow Total | 6m 32s | 4m 38s | 29% faster | 7.57 GB (91.66%) | commit build faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-import misses render as cache-bootstrap samples excluded from parity claims.
