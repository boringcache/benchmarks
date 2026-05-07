## Latest Benchmark Report

Generated: 2026-05-07 20:55 UTC

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
| Immich | Cold Build | 6m 11s | 4m 45s | 23% faster | 7.41 GB (77.13%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 24s | 9m 18s | 11% faster | 9.22 GB (90.02%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 2m 14s | 0m 13s | 90% faster | 4.57 GB (42.09%) | cold, workflow total faster; 3 paired samples |
| Storybook | Cold Build | 3m 33s | 5m 57s | 67% slower | 43.66 MB more (-5.97%) | workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 10m 45s | 11m 14s | 4% slower | 50.64 MB (6.09%) | warm, workflow total slower; 3 paired samples |
| Spring AI | Cold Build | 4m 23s | 5m 12s | 19% slower | 2.60 MB (0.28%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 37m 11s | 37m 21s | near tie | 406.38 MB more (-190.43%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 49m 22s | 50m 33s | near tie | 2.04 GB (73.46%) | workflow total slower; 3 paired samples |
| n8n | Cold Build | 5m 20s | 5m 23s | near tie | 15.77 MB more (-2.17%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 10s | 0m 26s | 155% slower | 4.65 GB (93.34%) | workflow total slower; tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 0m 53s | 158% slower | 226.95 MB (23.31%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 3m 51s | 6m 5s | 58% slower | 7.33 GB (76.93%) | workflow total slower; 3 paired samples |
| Mastodon | Commit Build | 2m 26s | 2m 5s | 14% faster | 8.93 GB (89.73%) | workflow total faster; 3 paired samples |
| PostHog | Commit Build | 19m 57s | 8m 22s | 58% faster | 5.88 GB (49.04%) | workflow total faster; 3 paired samples |
| Storybook | Commit Build | 4m 49s | 3m 30s | 27% faster | 815.45 MB (50.99%) | workflow total faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 5m 1s | 10m 13s | 104% slower | 1.84 GB (70.68%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 48s | 1m 5s | 34% slower | 1.76 GB (54.21%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 43s | 2m 57s | 312% slower | 326.01 MB more (-46.05%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 32m 28s | 32m 2s | near tie | 9.34 GB (92.26%) | 3 paired samples |
| n8n | Workflow Total | 6m 17s | 5m 3s | 20% faster | 8.37 GB (92.03%) | commit build faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
