## Latest Benchmark Report

Generated: 2026-05-13 13:19 UTC

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
| Hugo | Cold Build | 3m 49s | 3m 27s | 9% faster | 5.32 GB (94.12%) | workflow total faster; 3 paired samples |
| Hugo Go | Workflow Total | 3m 0s | 1m 31s | 49% faster | 706.43 MB more (-240.49%) | cold slower; BC used more storage |
| Immich | Cold Build | 5m 53s | 4m 38s | 21% faster | 7.76 GB (77.91%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 45s | 8m 43s | 19% faster | 9.63 GB (90.41%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 6m 16s | 0m 12s | 97% faster | 4.23 GB (39.86%) | cold, workflow total faster; 3 paired samples |
| Storybook | Cold Build | 4m 58s | 3m 45s | 25% faster | 43.13 MB more (-5.91%) | workflow total faster; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 11m 18s | 11m 28s | near tie | 50.14 MB (5.95%) | warm slower; 3 paired samples |
| Spring AI | Warm Build | 0m 32s | 0m 26s | 20% faster | 1.38 MB (0.15%) | workflow total slower; 2 paired samples |
| gRPC | Cold Build | 36m 29s | 25m 12s | 31% faster | 648.39 MB more (-611.68%) | mixed: warm slower; workflow total faster; BC used more storage |
| Zed | Workflow Total | 54m 16s | 52m 34s | 3% faster | 6.49 MB (0.23%) | 3 paired samples |
| n8n | Cold Build | 5m 29s | 5m 42s | 4% slower | 52.95 MB more (-7.07%) | warm slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 48s | 2m 55s | 4% slower | 5.66 GB (94.46%) | workflow total slower; 1 steady samples; 2/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 56s | 1m 12s | 29% slower | 365.50 MB (24.57%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 8m 41s | 4m 21s | 50% faster | 7.67 GB (77.72%) | workflow total faster; 1 steady samples; 2/3 bootstrap samples excluded |
| Mastodon | Commit Build | 2m 30s | 2m 5s | 17% faster | 8.98 GB (89.78%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Commit Build | 23m 4s | 11m 51s | 49% faster | 7.10 GB (53.21%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Storybook | Commit Build | 2m 31s | 6m 0s | 139% slower | 1.13 GB (59.94%) | workflow total slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 4m 46s | 7m 41s | 61% slower | 2.45 GB (73.29%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 2m 1s | 2m 55s | 45% slower | 2.33 GB (70.38%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 45s | 37m 16s | 4869% slower | 31.74 MB more (-4.39%) | workflow total slower; BC used more storage |
| Zed | Commit Build | 32m 34s | 43m 34s | 34% slower | 7.39 GB (68.8%) | workflow total slower; 3 paired samples |
| n8n | Commit Build | 2m 43s | 4m 24s | 62% slower | 2.44 GB (75.19%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
