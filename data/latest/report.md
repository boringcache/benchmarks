## Latest Benchmark Report

Generated: 2026-05-13 17:21 UTC

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
| Hugo | Cold Build | 4m 10s | 3m 22s | 19% faster | 6.06 GB (94.8%) | workflow total faster; 3 paired samples |
| Hugo Go | Workflow Total | 3m 0s | 1m 31s | 49% faster | 706.43 MB more (-240.49%) | cold slower; BC used more storage |
| Immich | Cold Build | 5m 39s | 4m 42s | 17% faster | 7.76 GB (77.92%) | mixed: warm slower; workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 44s | 9m 5s | 15% faster | 9.34 GB (90.14%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 3m 51s | 0m 27s | 88% faster | 4.76 GB (42.74%) | cold, workflow total faster; 3 paired samples |
| Storybook | Warm Build | 0m 53s | 0m 43s | 19% faster | 43.13 MB more (-5.91%) | BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 11m 18s | 11m 28s | near tie | 50.14 MB (5.95%) | warm slower; 3 paired samples |
| Spring AI | Warm Build | 0m 31s | 0m 28s | near tie | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 36m 29s | 25m 12s | 31% faster | 648.39 MB more (-611.68%) | mixed: warm slower; workflow total faster; BC used more storage |
| Zed | Warm Build | 17m 54s | 17m 47s | near tie | 6.60 MB (0.23%) | cold, workflow total slower; 3 paired samples |
| n8n | Cold Build | 5m 19s | 5m 29s | 3% slower | 53.00 MB more (-7.08%) | warm slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 2s | 2m 48s | 8% faster | 6.00 GB (94.75%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 48s | 0m 59s | 22% slower | 415.23 MB (24.75%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 3m 57s | 3m 39s | 8% faster | 7.87 GB (78.16%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Mastodon | Commit Build | 2m 26s | 1m 58s | 19% faster | 8.98 GB (89.78%) | workflow total faster; 1 steady samples; 2/3 bootstrap samples excluded |
| PostHog | Commit Build | 20m 16s | 8m 8s | 60% faster | 5.01 GB (44.35%) | workflow total faster; 3 paired samples |
| Storybook | Commit Build | 3m 10s | 3m 48s | 20% slower | 1.17 GB (60.64%) | workflow total slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 4m 46s | 7m 41s | 61% slower | 2.45 GB (73.29%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 2m 10s | 2m 51s | 31% slower | 2.33 GB (70.38%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 45s | 37m 16s | 4869% slower | 31.74 MB more (-4.39%) | workflow total slower; BC used more storage |
| Zed | Commit Build | 27m 18s | 36m 31s | 34% slower | 4.56 GB (59.87%) | workflow total slower; 3 paired samples |
| n8n | Commit Build | 3m 17s | 4m 35s | 40% slower | 2.51 GB (76.09%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
