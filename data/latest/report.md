## Latest Benchmark Report

Generated: 2026-05-06 21:00 UTC

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
| Immich | Cold Build | 6m 1s | 5m 9s | 14% faster | 7.80 GB (77.47%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 11m 20s | 9m 27s | 17% faster | 9.53 GB (90.4%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 2m 31s | 0m 14s | 91% faster | 3.96 GB (39.14%) | cold, workflow total faster; 3 paired samples |
| Storybook | Warm Build | 3m 30s | 0m 53s | 75% faster | 44.88 MB more (-6.15%) | BC used more storage; 3 paired samples |
| OpenTelemetry Java | Warm Build | 3m 28s | 0m 56s | 73% faster | 20.41 MB (2.52%) | 3 paired samples |
| Spring AI | Cold Build | 4m 1s | 4m 22s | 8% slower | 3.39 MB (0.36%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 33m 43s | 29m 7s | 14% faster | 308.70 MB more (-115.35%) | mixed: warm slower; workflow total faster; BC used more storage; 3 paired samples |
| Zed | Cold Build | 49m 36s | 50m 48s | near tie | 1.41 GB (50.74%) | warm, workflow total slower; 3 paired samples |
| n8n | Warm Build | 1m 39s | 1m 12s | 28% faster | 15.93 MB more (-2.29%) | cold, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 10s | 0m 26s | 155% slower | 4.65 GB (93.34%) | workflow total slower; tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 0m 53s | 158% slower | 226.95 MB (23.31%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 0m 15s | 0m 11s | near tie | 7.63 GB (77.06%) | tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Mastodon | Commit Build | 3m 16s | 2m 38s | 19% faster | 8.94 GB (89.83%) | workflow total faster; 3 paired samples |
| PostHog | Commit Build | 22m 18s | 10m 55s | 51% faster | 5.20 GB (46.86%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Storybook | Workflow Total | 3m 50s | 2m 46s | 28% faster | 793.40 MB (50.62%) | commit build faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 0m 56s | 1m 25s | 52% slower | 1.96 GB (72.92%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 1m 4s | 1m 21s | 26% slower | 1.92 GB (59.62%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 38s | 11m 3s | 1629% slower | 4.01 MB (0.45%) | workflow total slower; 3 paired samples |
| Zed | Workflow Total | 34m 36s | 34m 7s | near tie | 9.09 GB (79.42%) | 3 paired samples |
| n8n | Workflow Total | 4m 34s | 3m 25s | 25% faster | 7.79 GB (91.81%) | commit build faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
