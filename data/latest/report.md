## Latest Benchmark Report

Generated: 2026-05-08 16:58 UTC

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
| Hugo | Cold Build | 3m 31s | 3m 27s | near tie | 3.72 GB (91.79%) | 3 paired samples |
| Hugo Go | Cold Build | 1m 21s | 1m 20s | near tie | 452.48 MB more (-153.92%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Cold Build | 6m 43s | 4m 48s | 29% faster | 7.43 GB (77.17%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 46s | 9m 23s | 13% faster | 9.42 GB (90.22%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 2m 35s | 0m 13s | 91% faster | 5.20 GB (45.23%) | cold, workflow total faster; 3 paired samples |
| Storybook | Cold Build | 3m 32s | 5m 7s | 45% slower | 43.66 MB more (-5.97%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 11m 4s | 11m 13s | near tie | 50.57 MB (6.0%) | warm, workflow total slower; 3 paired samples |
| Spring AI | Cold Build | 4m 34s | 4m 21s | 5% faster | 1.39 MB (0.15%) | warm slower; 3 paired samples |
| gRPC | Cold Build | 30m 49s | 33m 17s | 8% slower | 640.84 MB more (-609.66%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 50m 33s | 48m 43s | 4% faster | 2.04 GB (73.47%) | 3 paired samples |
| n8n | Cold Build | 5m 22s | 5m 36s | 4% slower | 15.49 MB more (-2.07%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 9s | 0m 11s | near tie | 4.61 GB (93.29%) | workflow total slower; tiny run; setup dominates; 1 steady samples; 2/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 22s | 0m 54s | 149% slower | 204.95 MB (21.54%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 3m 56s | 4m 38s | 18% slower | 7.24 GB (76.71%) | workflow total slower; 2 steady samples; 1/3 bootstrap samples excluded |
| Mastodon | Commit Build | 2m 18s | 2m 5s | 9% faster | 9.41 GB (90.21%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Commit Build | 22m 46s | 11m 50s | 48% faster | 8.30 GB (57.94%) | workflow total faster; 3 paired samples |
| Storybook | Workflow Total | 4m 23s | 4m 12s | 4% faster | 822.89 MB (51.32%) | commit build faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 6m 18s | 7m 31s | 19% slower | 1.99 GB (72.02%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 53s | 4m 32s | 411% slower | 2.39 GB (72.15%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 2m 44s | 23m 4s | 746% slower | 521.58 MB more (-195.37%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 36m 49s | 36m 44s | near tie | 8.62 GB (92.14%) | commit build slower; 3 paired samples |
| n8n | Commit Build | 3m 38s | 3m 54s | 7% slower | 1013.13 MB (56.94%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
