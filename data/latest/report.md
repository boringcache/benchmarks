## Latest Benchmark Report

Generated: 2026-05-12 01:16 UTC

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
| Immich | Cold Build | 5m 47s | 5m 13s | 10% faster | 7.37 GB (77.0%) | mixed: warm slower; workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 13s | 9m 30s | 7% faster | 9.79 GB (90.56%) | workflow total faster; 3 paired samples |
| PostHog | Cold Build | 21m 21s | 15m 30s | 27% faster | 6.32 GB (49.87%) | workflow total faster; 3 paired samples |
| Storybook | Cold Build | 3m 47s | 3m 38s | 4% faster | 42.61 MB more (-5.83%) | BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 11m 15s | 11m 15s | near tie | 50.83 MB (6.03%) | warm slower; 3 paired samples |
| Spring AI | Warm Build | 0m 32s | 0m 30s | near tie | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 37m 18s | 32m 12s | 14% faster | 647.78 MB more (-611.25%) | mixed: warm slower; workflow total faster; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 53m 45s | 52m 28s | near tie | 6.19 MB (0.22%) | warm slower; 3 paired samples |
| n8n | Warm Build | 1m 38s | 1m 9s | 30% faster | 52.92 MB more (-7.07%) | cold slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 53s | 2m 43s | 6% faster | 3.93 GB (92.2%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 1m 2s | 200% slower | 72.42 MB more (-6.53%) | workflow total slower; BC used more storage; 3 paired samples |
| Immich | Commit Build | 6m 7s | 4m 14s | 31% faster | 7.37 GB (77.0%) | workflow total faster; 3 paired samples |
| Mastodon | Commit Build | 2m 59s | 2m 3s | 31% faster | 8.91 GB (89.71%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Workflow Total | 18m 49s | 14m 13s | 24% faster | 3.56 GB (36.24%) | commit build faster; 3 paired samples |
| Storybook | Commit Build | 1m 38s | 1m 57s | 20% slower | 1002.36 MB (56.45%) | workflow total slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 47s | 4m 43s | 164% slower | 2.10 GB (73.11%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 39s | 1m 43s | 163% slower | 2.39 GB (72.14%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 7m 22s | 24m 12s | 228% slower | 446.86 MB more (-81.43%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 29m 27s | 27m 52s | 5% faster | 4.59 GB (48.11%) | 3 paired samples |
| n8n | Commit Build | 3m 23s | 3m 29s | near tie | 1.44 GB (61.52%) | 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
