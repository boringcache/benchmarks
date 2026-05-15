## Latest Benchmark Report

Generated: 2026-05-15 05:52 UTC

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
| Hugo | Cold Build | 3m 46s | 3m 28s | 8% faster | 6.65 GB (95.24%) | workflow total faster; 3 paired samples |
| Hugo Go | Workflow Total | 3m 0s | 1m 31s | 49% faster | 706.43 MB more (-240.49%) | cold slower; BC used more storage |
| Immich | Cold Build | 6m 11s | 4m 38s | 25% faster | 8.23 GB (78.92%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 44s | 9m 5s | 15% faster | 9.34 GB (90.14%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 1m 53s | 0m 15s | 86% faster | 6.05 GB (48.55%) | cold, workflow total faster; 3 paired samples |
| Storybook | Cold Build | 4m 51s | 6m 0s | 24% slower | 43.51 MB more (-5.96%) | workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 10m 48s | 11m 25s | 6% slower | 50.07 MB (5.94%) | warm, workflow total slower |
| Spring AI | Warm Build | 0m 30s | 0m 29s | near tie | 1.39 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 38m 23s | 38m 14s | near tie | 648.32 MB more (-611.68%) | warm slower; BC used more storage |
| Zed | Workflow Total | 53m 30s | 51m 46s | 3% faster | 6.26 MB (0.22%) | 2 paired samples |
| n8n | Cold Build | 5m 32s | 5m 44s | 3% slower | 52.86 MB more (-7.06%) | warm, workflow total slower; BC used more storage; 2 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 25s | 3m 18s | cache import unavailable | 7.33 GB (95.66%) | cache import proxy_unreadable; Rolling cache import was unavailable, so this sample populated the rolling cache and is excluded from parity claims. |
| Hugo Go | Commit Build | 0m 38s | 1m 30s | 137% slower | 1.25 GB (56.07%) | workflow total slower |
| Immich | Commit Build | 2m 28s | 1m 55s | 22% faster | 7.66 GB (77.69%) | workflow total faster; 3 paired samples |
| Mastodon | Commit Build | 0m 17s | 9m 18s | cache import unavailable | 8.95 GB (89.75%) | cache import proxy_unreadable; Rolling cache import was unavailable, so this sample populated the rolling cache and is excluded from parity claims. |
| PostHog | Commit Build | 26m 4s | 12m 5s | 54% faster | 6.54 GB (51.61%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Storybook | Commit Build | 3m 30s | 3m 48s | 9% slower | 1.18 GB (60.97%) | workflow total slower |
| OpenTelemetry Java | Commit Build | 7m 44s | 12m 1s | 55% slower | 3.10 GB (80.01%) | workflow total slower |
| Spring AI | Commit Build | 0m 41s | 3m 50s | 461% slower | 2.39 GB (72.15%) | workflow total slower |
| gRPC | Commit Build | 0m 53s | 32m 15s | 3551% slower | 27.64 MB (3.53%) | workflow total slower |
| Zed | Commit Build | 34m 55s | 38m 28s | 10% slower | 8.38 GB (73.3%) | workflow total slower; 2 paired samples |
| n8n | Commit Build | 1m 9s | 5m 39s | 391% slower | 2.90 GB (78.72%) | workflow total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
