## Latest Benchmark Report

Generated: 2026-05-06 15:51 UTC

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
| Hugo | Cold Build | 3m 29s | 3m 30s | near tie | 5.97 GB (94.73%) | workflow total slower; 3 paired samples |
| Hugo Go | Cold Build | 1m 21s | 1m 20s | near tie | 452.40 MB more (-153.9%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Cold Build | 8m 38s | 5m 8s | 41% faster | 7.55 GB (76.88%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 11m 25s | 9m 27s | 17% faster | 9.34 GB (90.22%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 1m 56s | 0m 14s | 88% faster | 8.83 GB (59.0%) | cold, workflow total faster; 3 paired samples |
| Storybook | Warm Build | 3m 30s | 0m 53s | 75% faster | 44.88 MB more (-6.15%) | BC used more storage; 3 paired samples |
| OpenTelemetry Java | Warm Build | 3m 28s | 0m 56s | 73% faster | 20.41 MB (2.52%) | 3 paired samples |
| Spring AI | Cold Build | 4m 6s | 4m 37s | 12% slower | 3.46 MB (0.36%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 35m 45s | 35m 5s | near tie | 396.85 MB more (-148.27%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 50m 8s | 50m 24s | near tie | 52.75 MB (1.86%) | warm slower; 3 paired samples |
| n8n | Cold Build | 5m 18s | 5m 46s | 9% slower | 16.51 MB more (-2.4%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 10s | 0m 26s | 155% slower | 4.65 GB (93.34%) | workflow total slower; tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 0m 53s | 158% slower | 226.95 MB (23.31%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 6m 50s | 5m 12s | 24% faster | 7.40 GB (76.53%) | workflow total faster; 3 paired samples |
| Mastodon | Commit Build | 3m 4s | 2m 39s | 14% faster | 8.94 GB (89.83%) | workflow total faster; 3 paired samples |
| PostHog | Commit Build | 20m 5s | 13m 21s | 34% faster | 8.72 GB (59.05%) | workflow total faster; 3 paired samples |
| Storybook | Workflow Total | 3m 50s | 2m 46s | 28% faster | 793.40 MB (50.62%) | commit build faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 0m 56s | 1m 25s | 52% slower | 1.96 GB (72.92%) | workflow total slower; 3 paired samples |
| Spring AI | Workflow Total | 2m 9s | 2m 5s | 3% faster | 1.92 GB (59.72%) | 3 paired samples |
| gRPC | Commit Build | 0m 46s | 3m 5s | 299% slower | 45.99 MB (5.28%) | workflow total slower; 3 paired samples |
| Zed | Workflow Total | 36m 58s | 36m 25s | near tie | 4.45 GB (46.66%) | 3 paired samples |
| n8n | Workflow Total | 5m 3s | 3m 10s | 37% faster | 7.64 GB (91.73%) | commit build faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
