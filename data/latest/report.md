## Latest Benchmark Report

Generated: 2026-05-08 01:17 UTC

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
| PostHog | Cold Build | 20m 0s | 15m 25s | 23% faster | 8.23 GB (56.7%) | workflow total faster; 3 paired samples |
| Storybook | Cold Build | 3m 33s | 5m 57s | 67% slower | 43.66 MB more (-5.97%) | workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 10m 45s | 11m 14s | 4% slower | 50.64 MB (6.09%) | warm, workflow total slower; 3 paired samples |
| Spring AI | Cold Build | 4m 22s | 4m 17s | near tie | 1.39 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 37m 11s | 37m 21s | near tie | 406.38 MB more (-190.43%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 50m 8s | 49m 30s | near tie | 2.22 GB (80.07%) | warm slower; 3 paired samples |
| n8n | Cold Build | 5m 16s | 5m 20s | near tie | 15.78 MB more (-2.17%) | warm slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 10s | 0m 26s | 155% slower | 4.65 GB (93.34%) | workflow total slower; tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 0m 53s | 158% slower | 226.95 MB (23.31%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 3m 51s | 6m 5s | 58% slower | 7.33 GB (76.93%) | workflow total slower; 3 paired samples |
| Mastodon | Commit Build | 2m 26s | 2m 5s | 14% faster | 8.93 GB (89.73%) | workflow total faster; 3 paired samples |
| PostHog | Commit Build | 18m 30s | 9m 55s | 46% faster | 5.08 GB (45.08%) | workflow total faster; 3 paired samples |
| Storybook | Commit Build | 4m 49s | 3m 30s | 27% faster | 815.45 MB (50.99%) | workflow total faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 5m 1s | 10m 13s | 104% slower | 1.84 GB (70.68%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 1m 26s | 1m 46s | 23% slower | 1.78 GB (53.85%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 43s | 2m 57s | 312% slower | 326.01 MB more (-46.05%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Commit Build | 33m 45s | 24m 26s | 28% faster | 4.34 GB (84.69%) | workflow total faster; 3 paired samples |
| n8n | Workflow Total | 6m 16s | 4m 57s | 21% faster | 8.43 GB (92.08%) | commit build faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
