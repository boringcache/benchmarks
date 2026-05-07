## Latest Benchmark Report

Generated: 2026-05-07 05:45 UTC

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
| PostHog | Warm Build | 0m 42s | 0m 17s | 58% faster | 6.53 GB (51.49%) | cold, workflow total faster; 3 paired samples |
| Storybook | Warm Build | 3m 30s | 0m 53s | 75% faster | 44.88 MB more (-6.15%) | BC used more storage; 3 paired samples |
| OpenTelemetry Java | Warm Build | 3m 32s | 0m 57s | 73% faster | 35.57 MB (4.38%) | 3 paired samples |
| Spring AI | Cold Build | 4m 25s | 4m 17s | 3% faster | 3.13 MB (0.33%) | 3 paired samples |
| gRPC | Cold Build | 33m 15s | 35m 4s | 5% slower | 388.54 MB more (-145.19%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 49m 27s | 47m 32s | 4% faster | 2.05 GB (74.04%) | 3 paired samples |
| n8n | Cold Build | 5m 12s | 5m 19s | near tie | 15.89 MB more (-2.29%) | warm slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 10s | 0m 26s | 155% slower | 4.65 GB (93.34%) | workflow total slower; tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 0m 53s | 158% slower | 226.95 MB (23.31%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 0m 15s | 0m 11s | near tie | 7.63 GB (77.06%) | tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Mastodon | Commit Build | 3m 16s | 2m 38s | 19% faster | 8.94 GB (89.83%) | workflow total faster; 3 paired samples |
| PostHog | Commit Build | 20m 38s | 11m 0s | 47% faster | 4.66 GB (43.81%) | workflow total faster; 3 paired samples |
| Storybook | Workflow Total | 3m 50s | 2m 46s | 28% faster | 793.40 MB (50.62%) | commit build faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 36s | 4m 49s | 200% slower | 1.91 GB (73.16%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 1m 12s | 1m 22s | 13% slower | 1.92 GB (59.47%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 40s | 12m 57s | 1858% slower | 12.27 MB more (-1.36%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 32m 25s | 30m 43s | 5% faster | 10.68 GB (93.34%) | 3 paired samples |
| n8n | Workflow Total | 4m 8s | 3m 9s | 24% faster | 7.80 GB (91.83%) | commit build faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
