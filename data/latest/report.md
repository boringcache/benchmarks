## Latest Benchmark Report

Generated: 2026-05-07 09:23 UTC

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
| PostHog | Cold Build | 21m 9s | 15m 6s | 29% faster | 6.99 GB (53.18%) | workflow total faster; 3 paired samples |
| Storybook | Warm Build | 2m 35s | 0m 59s | 62% faster | 44.42 MB more (-6.08%) | workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Warm Build | 3m 32s | 0m 57s | 73% faster | 35.57 MB (4.38%) | 3 paired samples |
| Spring AI | Cold Build | 4m 25s | 4m 17s | 3% faster | 3.13 MB (0.33%) | 3 paired samples |
| gRPC | Cold Build | 35m 4s | 37m 40s | 7% slower | 302.29 MB more (-112.97%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 50m 9s | 46m 33s | 7% faster | 2.04 GB (73.46%) | warm, workflow total faster; 3 paired samples |
| n8n | Cold Build | 5m 20s | 5m 14s | near tie | 15.86 MB more (-2.25%) | warm slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 10s | 0m 26s | 155% slower | 4.65 GB (93.34%) | workflow total slower; tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 0m 53s | 158% slower | 226.95 MB (23.31%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 0m 15s | 0m 11s | near tie | 7.63 GB (77.06%) | tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Mastodon | Commit Build | 3m 16s | 2m 38s | 19% faster | 8.94 GB (89.83%) | workflow total faster; 3 paired samples |
| PostHog | Commit Build | 14m 56s | 10m 45s | 28% faster | 5.69 GB (49.09%) | workflow total faster; 3 paired samples |
| Storybook | Workflow Total | 4m 1s | 3m 0s | 26% faster | 770.35 MB (49.78%) | commit build faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 36s | 4m 49s | 200% slower | 1.91 GB (73.16%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 1m 12s | 1m 22s | 13% slower | 1.92 GB (59.47%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 37s | 4m 13s | 578% slower | 10.49 MB more (-1.12%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 43m 35s | 30m 24s | 30% faster | 7.77 GB (90.83%) | commit build faster; 3 paired samples |
| n8n | Workflow Total | 4m 58s | 3m 53s | 22% faster | 7.84 GB (91.75%) | commit build faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
