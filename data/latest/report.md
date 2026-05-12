## Latest Benchmark Report

Generated: 2026-05-12 17:18 UTC

### Lane Coverage

| Benchmark | Fresh | Rolling |
| --- | --- | --- |
| Hugo | yes | yes |
| Hugo Go | yes | yes |
| Immich | yes | yes |
| Mastodon | yes | yes |
| PostHog | yes | yes |
| Storybook | yes | yes |
| OpenTelemetry Java | yes | yes |
| Spring AI | yes | yes |
| gRPC | yes | yes |
| Zed | yes | yes |
| n8n | yes | yes |

### Fresh

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Warm Build | 0m 16s | 0m 6s | 63% faster | 4.72 GB (93.42%) | cold, workflow total slower |
| Hugo Go | Workflow Total | 3m 0s | 1m 31s | 49% faster | 706.43 MB more (-240.49%) | cold slower; BC used more storage |
| Immich | Warm Build | 0m 31s | 0m 14s | 56% faster | 8.67 GB (79.76%) | cold, workflow total faster; 2 paired samples |
| Mastodon | Cold Build | 11m 8s | 9m 48s | 12% faster | 9.58 GB (90.37%) | workflow total faster; 2 paired samples |
| PostHog | Cold Build | 21m 56s | 15m 50s | 28% faster | 5.87 GB (47.95%) | workflow total faster; 3 paired samples |
| Storybook | Workflow Total | 4m 55s | 4m 45s | 3% faster | 43.10 MB more (-5.9%) | cold, warm slower; BC used more storage |
| OpenTelemetry Java | Cold Build | 12m 33s | 11m 10s | 11% faster | 50.40 MB (5.98%) | mixed: warm slower; workflow total faster; 2 paired samples |
| Spring AI | Warm Build | 0m 32s | 0m 25s | 22% faster | 1.39 MB (0.15%) | workflow total slower |
| gRPC | Workflow Total | 37m 58s | 33m 8s | 13% faster | 648.38 MB more (-611.62%) | mixed: warm slower; cold faster; BC used more storage |
| Zed | Cold Build | 49m 43s | 50m 8s | near tie | 5.97 MB (0.21%) | warm, workflow total slower; 2 paired samples |
| n8n | Cold Build | 5m 20s | 6m 14s | 17% slower | 52.83 MB more (-7.06%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 8s | 0m 9s | near tie | 4.72 GB (93.42%) | tiny run; setup dominates |
| Hugo Go | Commit Build | 0m 25s | 0m 22s | near tie | 293.29 MB (22.66%) | tiny run; setup dominates |
| Immich | Commit Build | 0m 12s | 0m 20s | 67% slower | 7.79 GB (77.97%) | workflow total slower; 1 steady samples; 1/2 bootstrap samples excluded |
| Mastodon | Commit Build | 2m 39s | 2m 9s | 19% faster | 8.84 GB (89.64%) | workflow total faster; 1 steady samples; 1/2 bootstrap samples excluded |
| PostHog | Commit Build | 23m 29s | 11m 10s | 52% faster | 6.60 GB (51.98%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Storybook | Commit Build | 3m 52s | 8m 3s | 108% slower | 1.06 GB (58.46%) | workflow total slower |
| OpenTelemetry Java | Commit Build | 1m 32s | 6m 6s | 297% slower | 2.16 GB (73.64%) | workflow total slower; 2 paired samples |
| Spring AI | Commit Build | 1m 23s | 4m 14s | 206% slower | 2.39 GB (72.14%) | workflow total slower |
| gRPC | Commit Build | 0m 44s | 0m 59s | 34% slower | 799.08 MB more (-110.57%) | workflow total slower; BC used more storage |
| Zed | Commit Build | 37m 59s | 41m 10s | 8% slower | 8.40 GB (73.32%) | workflow total slower; 3 paired samples |
| n8n | Commit Build | 4m 11s | 4m 41s | 12% slower | 2.01 GB (71.3%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
