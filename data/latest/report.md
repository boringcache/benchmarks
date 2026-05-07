## Latest Benchmark Report

Generated: 2026-05-07 13:11 UTC

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
| Immich | Cold Build | 5m 51s | 5m 25s | 7% faster | 7.59 GB (77.16%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 12s | 9m 26s | 8% faster | 9.58 GB (90.37%) | workflow total faster; 3 paired samples |
| PostHog | Cold Build | 28m 46s | 15m 34s | 46% faster | 5.79 GB (48.13%) | mixed: warm slower; workflow total faster; 3 paired samples |
| Storybook | Warm Build | 1m 38s | 0m 52s | 47% faster | 43.94 MB more (-6.02%) | workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Warm Build | 3m 32s | 0m 57s | 73% faster | 35.57 MB (4.38%) | 3 paired samples |
| Spring AI | Cold Build | 4m 28s | 4m 30s | near tie | 2.61 MB (0.28%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 35m 4s | 37m 40s | 7% slower | 302.29 MB more (-112.97%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 53m 4s | 52m 3s | near tie | 2.04 GB (73.45%) | 3 paired samples |
| n8n | Cold Build | 5m 14s | 5m 27s | 4% slower | 15.81 MB more (-2.18%) | workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 10s | 0m 26s | 155% slower | 4.65 GB (93.34%) | workflow total slower; tiny run; setup dominates; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 0m 53s | 158% slower | 226.95 MB (23.31%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 0m 8s | 0m 9s | near tie | 7.56 GB (76.92%) | tiny run; setup dominates; 1 steady samples; 2/3 bootstrap samples excluded |
| Mastodon | Commit Build | 2m 21s | 2m 4s | 12% faster | 8.95 GB (89.76%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Commit Build | 21m 9s | 11m 32s | 45% faster | 5.38 GB (47.36%) | workflow total faster; 3 paired samples |
| Storybook | Commit Build | 5m 14s | 2m 42s | 48% faster | 747.17 MB (48.91%) | workflow total faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 36s | 4m 49s | 200% slower | 1.91 GB (73.16%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 1m 35s | 1m 52s | 19% slower | 1.76 GB (54.22%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 38s | 16m 26s | 2517% slower | 17.71 MB more (-1.9%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Commit Build | 20m 48s | 22m 23s | 8% slower | 5.07 GB (86.6%) | workflow total slower; 3 paired samples |
| n8n | Workflow Total | 6m 13s | 4m 54s | 21% faster | 8.06 GB (91.76%) | commit build faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
