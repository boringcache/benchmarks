## Latest Benchmark Report

Generated: 2026-05-06 14:44 UTC

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
| Immich | Cold Build | 5m 55s | 4m 59s | 16% faster | 8.27 GB (78.46%) | workflow total faster; 3 paired samples |
| Mastodon | Warm Build | 0m 19s | 0m 15s | near tie | 9.57 GB (90.44%) | cold, workflow total faster; 2 paired samples |
| PostHog | Cold Build | 25m 48s | 14m 45s | 43% faster | 4.09 GB (39.95%) | workflow total faster; 3 paired samples |
| OpenTelemetry Java | Warm Build | 3m 28s | 0m 56s | 73% faster | 20.41 MB (2.52%) | 3 paired samples |
| Spring AI | Cold Build | 4m 28s | 4m 35s | near tie | 3.14 MB (0.33%) | warm, workflow total slower; 3 paired samples |
| gRPC | Cold Build | 35m 22s | 37m 2s | 5% slower | 489.55 MB more (-182.91%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 49m 36s | 49m 39s | near tie | 53.09 MB (1.87%) | warm slower; 3 paired samples |
| n8n | Cold Build | 6m 1s | 5m 50s | 3% faster | 16.54 MB more (-2.4%) | warm slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 1m 10s | 1m 27s | cache bootstrap 1/3 | 5.97 GB (94.73%) | 3 paired samples; BC cache bootstrap 1/3; Rolling cache was unavailable for 1/3 BoringCache samples; those samples populated the rolling cache and are excluded from parity claims. |
| Immich | Commit Build | 4m 39s | 4m 20s | cache import unavailable | 7.45 GB (76.65%) | 3 paired samples; Rolling cache import was unavailable, so this sample populated the rolling cache and is excluded from parity claims. |
| Mastodon | Commit Build | 3m 17s | 2m 46s | cache bootstrap 2/2 | 8.92 GB (89.81%) | 2 paired samples; BC cache bootstrap 2/2; Rolling cache was unavailable for 2/2 BoringCache samples; those samples populated the rolling cache and are excluded from parity claims. |
| PostHog | Commit Build | 16m 53s | 11m 37s | 31% faster | 5.43 GB (47.97%) | workflow total faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 0m 56s | 1m 25s | 52% slower | 1.96 GB (72.92%) | workflow total slower; 3 paired samples |
| Spring AI | Workflow Total | 2m 59s | 2m 46s | 7% faster | 2.09 GB (65.02%) | commit build faster; 3 paired samples |
| gRPC | Commit Build | 0m 32s | 3m 2s | 469% slower | 184.28 MB more (-26.47%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 39m 57s | 39m 2s | near tie | 7.35 GB (64.26%) | 3 paired samples |
| n8n | Workflow Total | 5m 58s | 4m 57s | 17% faster | 7.45 GB (91.54%) | commit build faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-import misses render as cache-bootstrap samples excluded from parity claims.
