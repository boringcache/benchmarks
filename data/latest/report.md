## Latest Benchmark Report

Generated: 2026-05-15 17:07 UTC

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
| Hugo | Cold Build | 3m 14s | 3m 19s | near tie | 7.62 GB (95.82%) | workflow total slower; BC storage: remote CAS 340.26 MB |
| Hugo Go | Cold Build | 1m 20s | 1m 6s | 18% faster | 706.12 MB more (-240.01%) | BC used more storage; BC storage: remote CAS 746.62 MB, deps archive 253.70 MB |
| Immich | Cold Build | 6m 45s | 4m 20s | 36% faster | 7.92 GB (78.27%) | workflow total faster; BC storage: remote CAS 2.20 GB |
| Mastodon | Cold Build | 10m 8s | 9m 10s | 10% faster | 8.94 GB (89.75%) | workflow total faster; BC storage: remote CAS 1.02 GB |
| PostHog | Cold Build | 20m 38s | 16m 13s | 21% faster | 4.57 GB (41.6%) | mixed: warm slower; workflow total faster; BC storage: remote CAS 6.41 GB |
| Storybook | Cold Build | 3m 26s | 3m 35s | 4% slower | 44.66 MB more (-6.12%) | warm, workflow total slower; BC used more storage; BC storage: deps archive 734.85 MB, runtime archive 39.79 MB |
| OpenTelemetry Java | Cold Build | 11m 21s | 11m 19s | near tie | 51.58 MB (6.11%) | warm slower; BC storage: deps archive 792.60 MB |
| Spring AI | Warm Build | 0m 44s | 0m 29s | 34% faster | 2.00 MB (0.21%) | cold, workflow total slower; BC storage: remote CAS 175.18 MB, deps archive 770.98 MB |
| gRPC | Cold Build | 33m 0s | 30m 35s | 7% faster | 648.22 MB more (-611.6%) | mixed: warm slower; workflow total faster; BC used more storage; 2 paired samples |
| Zed | Cold Build | 51m 52s | 52m 58s | near tie | 6.50 MB (0.23%) | BC storage: remote CAS 2.04 GB, deps archive 753.40 MB |
| n8n | Workflow Total | 5m 55s | 5m 38s | 5% faster | 53.32 MB more (-7.11%) | mixed: warm slower; cold faster; BC used more storage; BC storage: remote CAS 37.79 MB, deps archive 701.29 MB, runtime archive 63.96 MB |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 7s | 0m 8s | near tie | 7.62 GB (95.82%) | tiny run; setup dominates; BC storage: remote CAS 340.26 MB |
| Hugo Go | Workflow Total | 1m 4s | 0m 27s | 58% faster | 1.01 GB (42.97%) | commit build faster; BC storage: remote CAS 1.09 GB, deps archive 262.95 MB |
| Immich | Commit Build | 0m 12s | 0m 9s | near tie | 7.63 GB (77.64%) | tiny run; setup dominates; BC storage: remote CAS 2.20 GB |
| Mastodon | Commit Build | 0m 13s | 0m 16s | near tie | 8.94 GB (89.75%) | workflow total slower; tiny run; setup dominates; BC storage: remote CAS 1.02 GB |
| PostHog | Commit Build | 3m 44s | 0m 16s | 93% faster | 3.10 GB (33.6%) | workflow total faster; BC storage: remote CAS 6.13 GB |
| Storybook | Workflow Total | 1m 8s | 0m 54s | 21% faster | 1.11 GB (59.43%) | BC storage: deps archive 734.80 MB, runtime archive 39.79 MB |
| OpenTelemetry Java | Workflow Total | 2m 13s | 1m 35s | 29% faster | 3.02 GB (79.59%) | commit build faster; BC storage: deps archive 792.41 MB |
| Spring AI | Workflow Total | 1m 7s | 0m 45s | 33% faster | 2.39 GB (72.0%) | commit build faster; BC storage: remote CAS 180.74 MB, deps archive 770.98 MB |
| gRPC | Commit Build | 38m 27s | 29m 3s | 24% faster | 1.02 MB (0.13%) | workflow total faster |
| Zed | Commit Build | 36m 30s | 31m 30s | 14% faster | 5.99 GB (52.62%) | workflow total faster; BC storage: remote CAS 4.66 GB, deps archive 753.41 MB |
| n8n | Commit Build | 1m 13s | 1m 8s | 7% faster | 3.08 GB (76.62%) | workflow total faster; BC storage: remote CAS 196.58 MB, deps archive 701.70 MB, runtime archive 63.96 MB |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
