## Latest Benchmark Report

Generated: 2026-05-15 13:10 UTC

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
| Hugo | Cold Build | 3m 28s | 3m 18s | 5% faster | 7.01 GB (95.47%) | workflow total faster |
| Hugo Go | Cold Build | 1m 20s | 1m 23s | 4% slower | 706.63 MB more (-240.44%) | workflow total slower; BC used more storage |
| Immich | Cold Build | 6m 49s | 4m 36s | 33% faster | 7.34 GB (76.94%) | workflow total faster |
| Mastodon | Cold Build | 9m 34s | 9m 25s | near tie | 9.84 GB (90.6%) | warm slower |
| PostHog | Workflow Total | 33m 55s | 18m 25s | 46% faster | 5.79 GB (47.46%) | mixed: warm slower; cold faster |
| Storybook | Warm Build | 4m 43s | 0m 47s | 83% faster | 44.06 MB more (-6.03%) | cold, workflow total faster; BC used more storage |
| OpenTelemetry Java | Cold Build | 11m 9s | 11m 11s | near tie | 50.07 MB (5.94%) | warm slower |
| Spring AI | Warm Build | 0m 31s | 0m 26s | near tie | 1.99 MB (0.21%) | cold, workflow total slower |
| gRPC | Cold Build | 33m 0s | 30m 35s | 7% faster | 648.22 MB more (-611.6%) | mixed: warm slower; workflow total faster; BC used more storage; 2 paired samples |
| Zed | Cold Build | 50m 19s | 43m 24s | 14% faster | 6.64 MB (0.23%) | workflow total faster |
| n8n | Warm Build | 1m 9s | 1m 8s | near tie | 53.42 MB more (-7.14%) | cold, workflow total slower; BC used more storage |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 6s | 0m 9s | near tie | 7.01 GB (95.47%) | workflow total slower; tiny run; setup dominates |
| Hugo Go | Workflow Total | 0m 53s | 0m 30s | 43% faster | 1.25 GB (56.12%) | commit build faster; tiny run; setup dominates |
| Immich | Commit Build | 0m 20s | 0m 9s | 55% faster | 7.34 GB (76.94%) | workflow total faster; tiny run; setup dominates |
| Mastodon | Commit Build | 0m 12s | 0m 11s | near tie | 8.95 GB (89.76%) | tiny run; setup dominates |
| PostHog | Commit Build | 5m 15s | 0m 12s | 96% faster | 3.45 GB (34.97%) | workflow total faster |
| Storybook | Workflow Total | 1m 43s | 1m 1s | 41% faster | 1.11 GB (59.51%) | commit build faster |
| OpenTelemetry Java | Commit Build | 1m 10s | 7m 17s | 524% slower | 3.14 GB (80.21%) | workflow total slower |
| Spring AI | Workflow Total | 1m 37s | 1m 28s | 9% faster | 2.39 GB (72.06%) | commit build faster |
| gRPC | Commit Build | 38m 27s | 29m 3s | 24% faster | 1.02 MB (0.13%) | workflow total faster |
| Zed | Workflow Total | 36m 59s | 36m 11s | near tie | 7.21 GB (63.06%) | 2 paired samples |
| n8n | Workflow Total | 4m 56s | 4m 45s | 4% faster | 2.92 GB (78.0%) | — |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
