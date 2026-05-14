## Latest Benchmark Report

Generated: 2026-05-14 13:10 UTC

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
| Immich | Cold Build | 5m 27s | 4m 46s | 13% faster | 7.35 GB (76.96%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 44s | 9m 5s | 15% faster | 9.34 GB (90.14%) | workflow total faster; 3 paired samples |
| PostHog | Cold Build | 19m 48s | 15m 24s | 22% faster | 9.37 GB (59.44%) | workflow total faster; 3 paired samples |
| Storybook | Cold Build | 4m 51s | 6m 0s | 24% slower | 43.51 MB more (-5.96%) | workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 11m 18s | 11m 28s | near tie | 50.14 MB (5.95%) | warm slower; 3 paired samples |
| Spring AI | Warm Build | 0m 30s | 0m 29s | near tie | 1.39 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 34m 59s | 34m 14s | near tie | 648.36 MB more (-611.77%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 53m 5s | 52m 30s | near tie | 889.33 MB (31.24%) | warm slower; 3 paired samples |
| n8n | Cold Build | 5m 5s | 5m 22s | 6% slower | 53.08 MB more (-7.09%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 3m 5s | 2m 45s | 11% faster | 6.68 GB (95.26%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 48s | 1m 9s | 43% slower | 626.79 MB (35.45%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 0m 13s | 4m 38s | cache import unavailable | 7.51 GB (77.36%) | 3 paired samples; cache bootstrap 3/3; cache import proxy_unreadable; Rolling cache import was unavailable, so this sample populated the rolling cache and is excluded from parity claims. |
| Mastodon | Commit Build | 2m 26s | 1m 58s | 19% faster | 8.98 GB (89.78%) | workflow total faster; 1 steady samples; 2/3 bootstrap samples excluded |
| PostHog | Commit Build | 18m 54s | 12m 32s | 34% faster | 8.77 GB (58.92%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Storybook | Commit Build | 5m 38s | 4m 2s | 28% faster | 1.21 GB (61.45%) | workflow total faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 4m 46s | 7m 41s | 61% slower | 2.45 GB (73.29%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 1m 51s | 3m 27s | 87% slower | 2.39 GB (72.14%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 0m 44s | 34m 35s | 4669% slower | 2.07 MB more (-0.27%) | workflow total slower; BC used more storage; 2 paired samples |
| Zed | Commit Build | 33m 22s | 37m 20s | 12% slower | 6.91 GB (67.3%) | workflow total slower; 3 paired samples |
| n8n | Commit Build | 3m 52s | 5m 11s | 34% slower | 2.67 GB (77.11%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
