## Latest Benchmark Report

Generated: 2026-05-08 20:50 UTC

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
| Hugo | Warm Build | 0m 9s | 0m 7s | near tie | 3.72 GB (91.8%) | cold, workflow total faster; 3 paired samples |
| Hugo Go | Cold Build | 1m 21s | 1m 20s | near tie | 452.52 MB more (-153.98%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Cold Build | 5m 21s | 5m 11s | 3% faster | 7.98 GB (78.4%) | warm slower; 3 paired samples |
| Mastodon | Cold Build | 10m 11s | 9m 20s | 8% faster | 9.22 GB (90.03%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 2m 27s | 0m 13s | 91% faster | 5.25 GB (45.26%) | cold, workflow total faster; 3 paired samples |
| Storybook | Warm Build | 0m 51s | 0m 46s | 10% faster | 43.81 MB more (-5.99%) | cold, workflow total faster; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 10m 59s | 11m 18s | near tie | 50.63 MB (6.01%) | warm, workflow total slower; 3 paired samples |
| Spring AI | Warm Build | 0m 30s | 0m 28s | near tie | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 32m 21s | 37m 15s | 15% slower | 641.80 MB more (-609.98%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 53m 17s | 51m 36s | 3% faster | 2.10 GB (75.72%) | 3 paired samples |
| n8n | Cold Build | 5m 21s | 5m 46s | 8% slower | 15.53 MB more (-2.07%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 9s | 0m 11s | near tie | 4.61 GB (93.29%) | workflow total slower; tiny run; setup dominates; 1 steady samples; 2/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 1m 4s | 206% slower | 169.64 MB (18.52%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 2m 49s | 2m 17s | 19% faster | 8.12 GB (78.7%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Mastodon | Commit Build | 1m 14s | 1m 7s | 9% faster | 8.94 GB (89.75%) | 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Commit Build | 16m 54s | 12m 56s | 23% faster | 3.99 GB (38.96%) | workflow total faster; 3 paired samples |
| Storybook | Commit Build | 1m 42s | 2m 44s | 61% slower | 893.13 MB (53.55%) | workflow total slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 5s | 4m 18s | 298% slower | 2.09 GB (73.01%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 51s | 3m 12s | 276% slower | 2.39 GB (72.14%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 7m 4s | 0m 49s | 89% faster | 604.42 MB more (-187.49%) | workflow total faster; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 39m 3s | 38m 47s | near tie | 8.77 GB (92.21%) | 3 paired samples |
| n8n | Commit Build | 2m 5s | 4m 56s | 136% slower | 1.05 GB (58.45%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
