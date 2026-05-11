## Latest Benchmark Report

Generated: 2026-05-11 01:22 UTC

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
| Hugo | Cold Build | 3m 23s | 3m 26s | near tie | 3.62 GB (91.6%) | workflow total slower; 3 paired samples |
| Hugo Go | Cold Build | 1m 21s | 1m 20s | near tie | 452.52 MB more (-153.98%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Cold Build | 5m 8s | 4m 42s | 9% faster | 7.88 GB (78.19%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 14s | 9m 13s | 10% faster | 9.53 GB (90.32%) | workflow total faster; 3 paired samples |
| PostHog | Cold Build | 22m 56s | 17m 56s | 22% faster | 7.23 GB (53.25%) | workflow total faster; 3 paired samples |
| Storybook | Warm Build | 0m 51s | 0m 46s | 10% faster | 43.81 MB more (-5.99%) | cold, workflow total faster; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 10m 21s | 11m 31s | 11% slower | 50.64 MB (6.01%) | warm, workflow total slower; 3 paired samples |
| Spring AI | Warm Build | 0m 30s | 0m 28s | near tie | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 35m 56s | 35m 30s | near tie | 647.83 MB more (-611.38%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 49m 42s | 49m 53s | near tie | 2.04 GB (73.48%) | 3 paired samples |
| n8n | Cold Build | 5m 34s | 5m 43s | near tie | 15.52 MB more (-2.07%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 49s | 2m 50s | near tie | 3.59 GB (91.53%) | 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 1m 4s | 206% slower | 169.64 MB (18.52%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 0m 9s | 0m 10s | near tie | 7.37 GB (77.03%) | workflow total slower; tiny run; setup dominates; 3 paired samples |
| Mastodon | Commit Build | 0m 15s | 0m 15s | near tie | 8.95 GB (89.75%) | workflow total slower; tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Commit Build | 16m 5s | 8m 9s | 49% faster | 5.07 GB (44.78%) | workflow total faster; 3 paired samples |
| Storybook | Commit Build | 1m 42s | 2m 44s | 61% slower | 893.13 MB (53.55%) | workflow total slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 19s | 4m 32s | 243% slower | 2.09 GB (73.01%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 51s | 3m 12s | 276% slower | 2.39 GB (72.14%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 2m 34s | 12m 52s | 402% slower | 381.20 MB more (-102.31%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Commit Build | 25m 27s | 31m 16s | 23% slower | 10.70 GB (93.57%) | workflow total slower; 3 paired samples |
| n8n | Commit Build | 2m 29s | 2m 35s | 4% slower | 1.07 GB (58.94%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
