## Latest Benchmark Report

Generated: 2026-05-13 01:21 UTC

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
| Hugo | Cold Build | 4m 0s | 3m 24s | 15% faster | 4.98 GB (93.75%) | mixed: warm slower; workflow total faster |
| Hugo Go | Workflow Total | 3m 0s | 1m 31s | 49% faster | 706.43 MB more (-240.49%) | cold slower; BC used more storage |
| Immich | Cold Build | 5m 24s | 4m 40s | 14% faster | 7.49 GB (77.28%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 33s | 8m 52s | 16% faster | 9.70 GB (90.47%) | workflow total faster; 3 paired samples |
| PostHog | Cold Build | 20m 40s | 15m 26s | 25% faster | 10.66 GB (62.55%) | workflow total faster; 3 paired samples |
| Storybook | Warm Build | 0m 45s | 0m 42s | near tie | 43.08 MB more (-5.9%) | BC used more storage; 2 paired samples |
| OpenTelemetry Java | Cold Build | 11m 18s | 11m 28s | near tie | 50.14 MB (5.95%) | warm slower; 3 paired samples |
| Spring AI | Warm Build | 0m 32s | 0m 26s | 20% faster | 1.38 MB (0.15%) | workflow total slower; 2 paired samples |
| gRPC | Cold Build | 36m 29s | 25m 12s | 31% faster | 648.39 MB more (-611.68%) | mixed: warm slower; workflow total faster; BC used more storage |
| Zed | Warm Build | 17m 47s | 17m 15s | near tie | 6.30 MB (0.22%) | 3 paired samples |
| n8n | Workflow Total | 6m 57s | 6m 35s | 5% faster | 52.85 MB more (-7.06%) | mixed: warm slower; cold faster; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 11s | 3m 23s | cache import unavailable | 4.98 GB (93.75%) | cache import proxy_unreadable; Rolling cache import was unavailable, so this sample populated the rolling cache and is excluded from parity claims. |
| Hugo Go | Commit Build | 0m 55s | 1m 22s | 49% slower | 359.02 MB (26.41%) | workflow total slower |
| Immich | Commit Build | 0m 19s | 0m 11s | 42% faster | 7.51 GB (77.33%) | workflow total faster; tiny run; setup dominates; 1 steady samples; 2/3 bootstrap samples excluded |
| Mastodon | Commit Build | 2m 33s | 2m 6s | 17% faster | 8.93 GB (89.73%) | workflow total faster; 3 paired samples |
| PostHog | Commit Build | 22m 22s | 10m 49s | 52% faster | 13.07 GB (68.16%) | workflow total faster; 1 steady samples; 2/3 bootstrap samples excluded |
| Storybook | Commit Build | 3m 42s | 9m 23s | 154% slower | 1.08 GB (58.9%) | workflow total slower; 2 paired samples |
| OpenTelemetry Java | Commit Build | 4m 46s | 7m 41s | 61% slower | 2.45 GB (73.29%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 2m 1s | 2m 55s | 45% slower | 2.33 GB (70.38%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 45s | 37m 16s | 4869% slower | 31.74 MB more (-4.39%) | workflow total slower; BC used more storage |
| Zed | Commit Build | 33m 55s | 37m 16s | 10% slower | 2.49 GB (36.31%) | workflow total slower; 3 paired samples |
| n8n | Commit Build | 3m 15s | 3m 17s | near tie | 2.10 GB (70.68%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
