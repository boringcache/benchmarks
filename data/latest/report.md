## Latest Benchmark Report

Generated: 2026-05-08 09:03 UTC

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
| Hugo | Cold Build | 3m 29s | 3m 24s | near tie | 4.14 GB (92.57%) | 3 paired samples |
| Hugo Go | Cold Build | 1m 21s | 1m 20s | near tie | 452.48 MB more (-153.92%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Cold Build | 6m 32s | 4m 47s | 27% faster | 7.43 GB (77.18%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 9m 39s | 9m 20s | 3% faster | 9.42 GB (90.21%) | 3 paired samples |
| PostHog | Warm Build | 0m 53s | 0m 11s | 78% faster | 5.70 GB (47.56%) | cold, workflow total faster; 3 paired samples |
| Storybook | Cold Build | 3m 32s | 5m 7s | 45% slower | 43.66 MB more (-5.97%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 10m 47s | 11m 24s | 6% slower | 50.59 MB (6.08%) | warm, workflow total slower; 3 paired samples |
| Spring AI | Cold Build | 3m 56s | 4m 22s | 11% slower | 1.39 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 35m 16s | 37m 54s | 7% slower | 406.38 MB more (-190.42%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 49m 46s | 50m 5s | near tie | 2.04 GB (73.47%) | 3 paired samples |
| n8n | Cold Build | 5m 26s | 5m 53s | 8% slower | 15.83 MB more (-2.18%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 10s | 0m 26s | 155% slower | 4.65 GB (93.34%) | workflow total slower; tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 22s | 0m 54s | 149% slower | 204.95 MB (21.54%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 3m 50s | 6m 3s | 58% slower | 7.29 GB (76.82%) | workflow total slower; 3 paired samples |
| Mastodon | Commit Build | 2m 37s | 2m 8s | 18% faster | 8.96 GB (89.76%) | workflow total faster; 1 steady samples; 2/3 bootstrap samples excluded |
| PostHog | Commit Build | 13m 5s | 8m 3s | 38% faster | 10.32 GB (62.82%) | workflow total faster; 3 paired samples |
| Storybook | Workflow Total | 4m 23s | 4m 12s | 4% faster | 822.89 MB (51.32%) | commit build faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 2m 6s | 7m 44s | 269% slower | 1.87 GB (70.98%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 2m 18s | 2m 39s | 15% slower | 1.93 GB (58.23%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 42s | 12m 47s | 1741% slower | 181.32 MB more (-25.44%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Commit Build | 25m 20s | 32m 8s | 27% slower | 5.83 GB (88.15%) | workflow total slower; 3 paired samples |
| n8n | Workflow Total | 6m 26s | 6m 8s | 5% faster | 5.72 GB (88.75%) | 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
