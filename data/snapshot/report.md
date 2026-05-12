## Latest Benchmark Report

Generated: 2026-05-12 09:26 UTC

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
| Hugo | Cold Build | 3m 29s | 3m 24s | near tie | 4.10 GB (92.51%) | 3 paired samples |
| Hugo Go | Cold Build | 1m 19s | 1m 22s | 3% slower | 621.95 MB more (-211.74%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Cold Build | 6m 28s | 4m 41s | 28% faster | 8.07 GB (78.58%) | mixed: warm slower; workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 13s | 9m 30s | 7% faster | 9.79 GB (90.56%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 3m 29s | 0m 18s | 91% faster | 4.74 GB (42.74%) | cold, workflow total faster; 3 paired samples |
| Storybook | Cold Build | 4m 54s | 3m 35s | 27% faster | 42.61 MB more (-5.83%) | workflow total faster; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 11m 15s | 11m 15s | near tie | 50.83 MB (6.03%) | warm slower; 3 paired samples |
| Spring AI | Warm Build | 0m 32s | 0m 30s | near tie | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 35m 21s | 35m 33s | near tie | 648.17 MB more (-611.42%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 46m 50s | 50m 35s | 8% slower | 6.05 MB (0.21%) | workflow total slower; 3 paired samples |
| n8n | Cold Build | 5m 27s | 5m 33s | near tie | 52.93 MB more (-7.07%) | warm slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 53s | 2m 43s | 6% faster | 3.93 GB (92.2%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 1m 2s | 200% slower | 72.42 MB more (-6.53%) | workflow total slower; BC used more storage; 3 paired samples |
| Immich | Commit Build | 8m 3s | 2m 28s | 69% faster | 8.30 GB (79.04%) | workflow total faster; 3 paired samples |
| Mastodon | Commit Build | 2m 59s | 2m 3s | 31% faster | 8.91 GB (89.71%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Commit Build | 19m 27s | 11m 57s | 39% faster | 6.26 GB (49.99%) | workflow total faster; 3 paired samples |
| Storybook | Commit Build | 2m 37s | 2m 45s | 5% slower | 1.00 GB (56.97%) | 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 47s | 4m 43s | 164% slower | 2.10 GB (73.11%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 39s | 1m 43s | 163% slower | 2.39 GB (72.14%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 5m 49s | 5m 17s | 9% faster | 712.56 MB more (-105.48%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 30m 19s | 29m 19s | 3% faster | 5.78 GB (50.44%) | 3 paired samples |
| n8n | Commit Build | 3m 52s | 3m 46s | near tie | 1.48 GB (61.17%) | 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
