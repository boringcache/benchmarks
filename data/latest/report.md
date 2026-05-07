## Latest Benchmark Report

Generated: 2026-05-07 17:10 UTC

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
| Immich | Cold Build | 6m 57s | 4m 49s | 31% faster | 7.81 GB (78.05%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 9m 50s | 9m 30s | 3% faster | 9.45 GB (90.24%) | 3 paired samples |
| PostHog | Cold Build | 20m 36s | 15m 31s | 25% faster | 6.57 GB (51.12%) | workflow total faster; 3 paired samples |
| Storybook | Cold Build | 3m 39s | 5m 4s | 39% slower | 43.66 MB more (-5.97%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Warm Build | 3m 32s | 0m 57s | 73% faster | 35.57 MB (4.38%) | 3 paired samples |
| Spring AI | Cold Build | 4m 23s | 5m 12s | 19% slower | 2.60 MB (0.28%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 35m 4s | 37m 40s | 7% slower | 302.29 MB more (-112.97%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 50m 32s | 50m 21s | near tie | 2.04 GB (73.46%) | workflow total slower; 3 paired samples |
| n8n | Cold Build | 5m 34s | 5m 34s | near tie | 15.75 MB more (-2.17%) | warm slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 10s | 0m 26s | 155% slower | 4.65 GB (93.34%) | workflow total slower; tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 0m 53s | 158% slower | 226.95 MB (23.31%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 1m 55s | 1m 28s | 24% faster | 7.56 GB (77.47%) | workflow total faster; 3 paired samples |
| Mastodon | Commit Build | 2m 26s | 2m 5s | 14% faster | 8.96 GB (89.76%) | workflow total faster; 3 paired samples |
| PostHog | Commit Build | 23m 55s | 11m 12s | 53% faster | 4.85 GB (44.64%) | workflow total faster; 3 paired samples |
| Storybook | Commit Build | 6m 45s | 3m 38s | 46% faster | 774.23 MB (49.7%) | workflow total faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 36s | 4m 49s | 200% slower | 1.91 GB (73.16%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 48s | 1m 5s | 34% slower | 1.76 GB (54.21%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 41s | 4m 16s | 519% slower | 17.69 MB more (-1.9%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Commit Build | 32m 58s | 33m 9s | near tie | 7.13 GB (90.09%) | 3 paired samples |
| n8n | Workflow Total | 5m 52s | 4m 23s | 25% faster | 8.28 GB (91.94%) | commit build faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
