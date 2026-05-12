## Latest Benchmark Report

Generated: 2026-05-12 11:16 UTC

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
| Hugo | Warm Build | 0m 16s | 0m 6s | 63% faster | 4.72 GB (93.42%) | cold, workflow total slower |
| Hugo Go | Workflow Total | 3m 0s | 1m 31s | 49% faster | 706.43 MB more (-240.49%) | cold slower; BC used more storage |
| Immich | Cold Build | 5m 53s | 5m 43s | near tie | 7.40 GB (77.08%) | — |
| Mastodon | Warm Build | 0m 12s | 0m 9s | near tie | 9.39 GB (90.19%) | cold, workflow total faster |
| PostHog | Workflow Total | 22m 16s | 18m 10s | 18% faster | 7.30 GB (53.47%) | mixed: warm slower; cold faster |
| Storybook | Cold Build | 3m 41s | 5m 36s | 52% slower | 42.50 MB more (-5.81%) | workflow total slower; BC used more storage |
| OpenTelemetry Java | Cold Build | 12m 10s | 10m 50s | 11% faster | 50.59 MB (6.0%) | mixed: warm slower; workflow total faster |
| Spring AI | Warm Build | 0m 32s | 0m 23s | 28% faster | 1.39 MB (0.15%) | mixed: cold slower; workflow total faster |
| gRPC | Cold Build | 37m 30s | 36m 33s | near tie | 648.38 MB more (-611.63%) | warm slower; BC used more storage |
| Zed | Warm Build | 17m 38s | 17m 37s | near tie | 6.52 MB (0.23%) | — |
| n8n | Cold Build | 5m 32s | 5m 17s | 5% faster | 52.92 MB more (-7.07%) | mixed: warm slower; workflow total faster; BC used more storage |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 8s | 0m 9s | near tie | 4.72 GB (93.42%) | tiny run; setup dominates |
| Hugo Go | Commit Build | 0m 25s | 0m 22s | near tie | 293.29 MB (22.66%) | tiny run; setup dominates |
| Immich | Commit Build | 0m 16s | 0m 45s | 181% slower | 7.38 GB (77.04%) | workflow total slower |
| Mastodon | Commit Build | 0m 16s | 0m 16s | near tie | 8.97 GB (89.77%) | tiny run; setup dominates |
| PostHog | Commit Build | 22m 10s | 0m 17s | 99% faster | 8.45 GB (58.18%) | workflow total faster |
| Storybook | Commit Build | 0m 43s | 1m 5s | 51% slower | 1.04 GB (57.89%) | workflow total slower |
| OpenTelemetry Java | Workflow Total | 1m 44s | 1m 27s | 16% faster | 2.16 GB (73.66%) | — |
| Spring AI | Workflow Total | 1m 0s | 0m 42s | 30% faster | 2.22 GB (67.01%) | commit build faster; tiny run; setup dominates |
| gRPC | Commit Build | 0m 43s | 13m 15s | 1771% slower | 784.38 MB more (-108.54%) | workflow total slower; BC used more storage; 2 paired samples |
| Zed | Workflow Total | 39m 53s | 38m 4s | 5% faster | 4.72 GB (41.23%) | — |
| n8n | Workflow Total | 1m 53s | 1m 32s | 19% faster | 1.61 GB (61.06%) | commit build faster |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
