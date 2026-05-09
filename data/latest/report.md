## Latest Benchmark Report

Generated: 2026-05-09 09:04 UTC

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
| Hugo | Warm Build | 0m 9s | 0m 7s | near tie | 3.72 GB (91.8%) | cold, workflow total faster; 3 paired samples |
| Hugo Go | Cold Build | 1m 21s | 1m 20s | near tie | 452.52 MB more (-153.98%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Cold Build | 5m 19s | 4m 41s | 12% faster | 8.50 GB (79.46%) | mixed: warm slower; workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 11s | 9m 20s | 8% faster | 9.22 GB (90.03%) | workflow total faster; 3 paired samples |
| PostHog | Cold Build | 28m 12s | 15m 37s | 45% faster | 5.81 GB (47.8%) | workflow total faster; 3 paired samples |
| Storybook | Warm Build | 0m 51s | 0m 46s | 10% faster | 43.81 MB more (-5.99%) | cold, workflow total faster; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 10m 21s | 11m 31s | 11% slower | 50.64 MB (6.01%) | warm, workflow total slower; 3 paired samples |
| Spring AI | Warm Build | 0m 30s | 0m 28s | near tie | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 37m 28s | 35m 15s | 6% faster | 645.88 MB more (-610.94%) | mixed: warm slower; workflow total faster; BC used more storage; 3 paired samples |
| Zed | Warm Build | 18m 3s | 17m 29s | 3% faster | 2.04 GB (73.48%) | cold slower; 3 paired samples |
| n8n | Cold Build | 5m 21s | 5m 46s | 8% slower | 15.53 MB more (-2.07%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 9s | 0m 11s | near tie | 4.61 GB (93.29%) | workflow total slower; tiny run; setup dominates; 1 steady samples; 2/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 1m 4s | 206% slower | 169.64 MB (18.52%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 0m 13s | 0m 10s | near tie | 7.68 GB (77.74%) | tiny run; setup dominates; 3 paired samples |
| Mastodon | Commit Build | 1m 14s | 1m 7s | 9% faster | 8.94 GB (89.75%) | 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Commit Build | 17m 37s | 9m 49s | 44% faster | 4.66 GB (42.7%) | workflow total faster; 3 paired samples |
| Storybook | Commit Build | 1m 42s | 2m 44s | 61% slower | 893.13 MB (53.55%) | workflow total slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 19s | 4m 32s | 243% slower | 2.09 GB (73.01%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 51s | 3m 12s | 276% slower | 2.39 GB (72.14%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 2m 33s | 12m 51s | 404% slower | 467.82 MB more (-132.63%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 34m 45s | 34m 18s | near tie | 8.81 GB (92.29%) | 3 paired samples |
| n8n | Commit Build | 1m 47s | 3m 24s | 90% slower | 1.05 GB (58.5%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
