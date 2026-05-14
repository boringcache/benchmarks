## Latest Benchmark Report

Generated: 2026-05-14 05:48 UTC

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
| Hugo | Cold Build | 3m 51s | 3m 22s | 12% faster | 6.71 GB (95.28%) | workflow total faster; 3 paired samples |
| Hugo Go | Workflow Total | 3m 0s | 1m 31s | 49% faster | 706.43 MB more (-240.49%) | cold slower; BC used more storage |
| Immich | Cold Build | 5m 36s | 4m 53s | 13% faster | 7.47 GB (77.25%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 44s | 9m 5s | 15% faster | 9.34 GB (90.14%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 2m 15s | 0m 21s | 85% faster | 5.73 GB (47.25%) | cold, workflow total faster; 3 paired samples |
| Storybook | Warm Build | 0m 53s | 0m 43s | 19% faster | 43.13 MB more (-5.91%) | BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 11m 18s | 11m 28s | near tie | 50.14 MB (5.95%) | warm slower; 3 paired samples |
| Spring AI | Cold Build | 4m 13s | 4m 26s | 5% slower | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 34m 59s | 34m 14s | near tie | 648.36 MB more (-611.77%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 47m 11s | 47m 10s | near tie | 1.30 GB (46.75%) | warm, workflow total slower; 3 paired samples |
| n8n | Cold Build | 5m 31s | 5m 33s | near tie | 52.92 MB more (-7.06%) | warm slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 5s | 2m 45s | 11% faster | 6.68 GB (95.26%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 48s | 1m 9s | 43% slower | 626.79 MB (35.45%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 0m 15s | 0m 12s | near tie | 7.16 GB (76.49%) | tiny run; setup dominates; 1 steady samples; 2/3 bootstrap samples excluded |
| Mastodon | Commit Build | 2m 26s | 1m 58s | 19% faster | 8.98 GB (89.78%) | workflow total faster; 1 steady samples; 2/3 bootstrap samples excluded |
| PostHog | Commit Build | 20m 37s | 12m 16s | 41% faster | 8.64 GB (58.56%) | workflow total faster; 1 steady samples; 2/3 bootstrap samples excluded |
| Storybook | Commit Build | 3m 10s | 3m 48s | 20% slower | 1.17 GB (60.64%) | workflow total slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 4m 46s | 7m 41s | 61% slower | 2.45 GB (73.29%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 1m 21s | 3m 12s | 137% slower | 2.39 GB (72.13%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 44s | 34m 35s | 4669% slower | 2.07 MB more (-0.27%) | workflow total slower; BC used more storage; 2 paired samples |
| Zed | Commit Build | 34m 42s | 38m 44s | 12% slower | 2.67 GB (36.21%) | workflow total slower; 3 paired samples |
| n8n | Commit Build | 3m 22s | 3m 46s | 12% slower | 2.56 GB (76.36%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
