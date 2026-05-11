## Latest Benchmark Report

Generated: 2026-05-11 09:48 UTC

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
| Hugo | Cold Build | 3m 23s | 3m 26s | near tie | 3.62 GB (91.6%) | workflow total slower; 3 paired samples |
| Hugo Go | Cold Build | 1m 21s | 1m 20s | near tie | 452.52 MB more (-153.98%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Cold Build | 5m 8s | 4m 42s | 9% faster | 7.88 GB (78.19%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 4s | 9m 20s | 7% faster | 9.67 GB (90.45%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 2m 47s | 0m 13s | 92% faster | 3.98 GB (38.51%) | cold, workflow total faster; 3 paired samples |
| Storybook | Cold Build | 3m 25s | 3m 33s | 4% slower | 43.39 MB more (-5.94%) | workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 10m 21s | 11m 31s | 11% slower | 50.64 MB (6.01%) | warm, workflow total slower; 3 paired samples |
| Spring AI | Warm Build | 0m 30s | 0m 28s | near tie | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 35m 37s | 38m 24s | 8% slower | 647.78 MB more (-611.24%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 50m 0s | 50m 8s | near tie | 2.04 GB (73.48%) | 3 paired samples |
| n8n | Cold Build | 5m 36s | 5m 38s | near tie | 15.53 MB more (-2.07%) | warm slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 49s | 2m 50s | near tie | 3.59 GB (91.53%) | 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 1m 4s | 206% slower | 169.64 MB (18.52%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 0m 9s | 0m 10s | near tie | 7.37 GB (77.03%) | workflow total slower; tiny run; setup dominates; 3 paired samples |
| Mastodon | Commit Build | 1m 32s | 1m 9s | 25% faster | 8.95 GB (89.76%) | workflow total faster; 3 paired samples |
| PostHog | Commit Build | 18m 59s | 12m 10s | 36% faster | 4.86 GB (44.09%) | workflow total faster; 3 paired samples |
| Storybook | Commit Build | 2m 36s | 2m 40s | near tie | 910.90 MB (54.06%) | workflow total slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 19s | 4m 32s | 243% slower | 2.09 GB (73.01%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 51s | 3m 12s | 276% slower | 2.39 GB (72.14%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 7m 14s | 7m 27s | near tie | 407.65 MB more (-103.25%) | BC used more storage; 3 paired samples |
| Zed | Commit Build | 21m 15s | 27m 36s | 30% slower | 10.72 GB (93.58%) | workflow total slower; 3 paired samples |
| n8n | Commit Build | 2m 36s | 2m 30s | 4% faster | 1.10 GB (59.54%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
