## Latest Benchmark Report

Generated: 2026-05-16 05:41 UTC

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
| Hugo | Cold Build | 3m 26s | 3m 21s | near tie | 7.75 GB (95.89%) | BC storage: remote CAS 340.26 MB; 2 paired samples |
| Hugo Go | Cold Build | 1m 20s | 1m 6s | 18% faster | 706.12 MB more (-240.01%) | BC used more storage; BC storage: remote CAS 746.62 MB, deps archive 253.70 MB |
| Immich | Cold Build | 5m 24s | 4m 28s | 17% faster | 8.22 GB (78.9%) | workflow total faster; BC storage: remote CAS 2.20 GB; 3 paired samples |
| Mastodon | Cold Build | 10m 8s | 9m 10s | 10% faster | 8.94 GB (89.75%) | workflow total faster; BC storage: remote CAS 1.02 GB |
| PostHog | Cold Build | 26m 28s | 15m 7s | 43% faster | 8.74 GB (57.65%) | workflow total faster; BC storage: remote CAS 6.42 GB; 3 paired samples |
| Storybook | Cold Build | 3m 26s | 3m 35s | 4% slower | 44.66 MB more (-6.12%) | warm, workflow total slower; BC used more storage; BC storage: deps archive 734.85 MB, runtime archive 39.79 MB |
| OpenTelemetry Java | Cold Build | 11m 21s | 11m 19s | near tie | 51.58 MB (6.11%) | warm slower; BC storage: deps archive 792.60 MB |
| Spring AI | Warm Build | 0m 44s | 0m 29s | 34% faster | 2.00 MB (0.21%) | cold, workflow total slower; BC storage: remote CAS 175.18 MB, deps archive 770.98 MB |
| gRPC | Cold Build | 31m 42s | 34m 56s | 10% slower | 648.06 MB more (-611.07%) | warm, workflow total slower; BC used more storage; BC storage: remote CAS 754.11 MB; 2 paired samples |
| Zed | Warm Build | 18m 3s | 18m 1s | near tie | 5.90 MB (0.21%) | cold slower; BC storage: remote CAS 2.04 GB, deps archive 753.56 MB; 3 paired samples |
| n8n | Workflow Total | 5m 59s | 5m 47s | 3% faster | 53.33 MB more (-7.11%) | warm slower; BC used more storage; BC storage: remote CAS 37.79 MB, deps archive 701.29 MB, runtime archive 63.96 MB; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 1m 27s | 1m 31s | 5% slower | 7.75 GB (95.89%) | workflow total slower; BC storage: remote CAS 340.26 MB; 2 paired samples |
| Hugo Go | Workflow Total | 1m 16s | 0m 50s | 34% faster | 861.66 MB (35.14%) | commit build faster; BC storage: remote CAS 1.30 GB, deps archive 262.95 MB; 2 paired samples |
| Immich | Commit Build | 1m 19s | 1m 11s | 10% faster | 7.42 GB (77.15%) | workflow total faster; BC storage: remote CAS 2.20 GB; 3 paired samples |
| Mastodon | Commit Build | 0m 13s | 0m 16s | near tie | 8.94 GB (89.75%) | workflow total slower; tiny run; setup dominates; BC storage: remote CAS 1.02 GB |
| PostHog | Commit Build | 16m 8s | 11m 28s | 29% faster | 4.77 GB (43.33%) | workflow total faster; BC storage: remote CAS 6.23 GB; 3 paired samples |
| Storybook | Workflow Total | 1m 8s | 0m 54s | 21% faster | 1.11 GB (59.43%) | BC storage: deps archive 734.80 MB, runtime archive 39.79 MB |
| OpenTelemetry Java | Workflow Total | 2m 13s | 1m 35s | 29% faster | 3.02 GB (79.59%) | commit build faster; BC storage: deps archive 792.41 MB |
| Spring AI | Workflow Total | 1m 7s | 0m 45s | 33% faster | 2.39 GB (72.0%) | commit build faster; BC storage: remote CAS 180.74 MB, deps archive 770.98 MB |
| gRPC | Commit Build | 0m 46s | 19m 21s | 2424% slower | 10.66 MB more (-1.35%) | workflow total slower; BC used more storage; BC storage: remote CAS 798.03 MB; 2 paired samples |
| Zed | Workflow Total | 34m 18s | 32m 56s | 4% faster | 4.32 GB (37.78%) | BC storage: remote CAS 6.37 GB, deps archive 753.41 MB; 3 paired samples |
| n8n | Workflow Total | 2m 7s | 1m 52s | 12% faster | 3.08 GB (76.61%) | commit build faster; BC storage: remote CAS 197.45 MB, deps archive 701.70 MB, runtime archive 63.96 MB; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
