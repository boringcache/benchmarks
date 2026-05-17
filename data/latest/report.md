## Latest Benchmark Report

Generated: 2026-05-17 21:55 UTC

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
| Hugo | Cold Build | 3m 13s | 3m 31s | 9% slower | 7.22 GB (95.6%) | workflow total slower; BC storage: remote CAS 340.26 MB |
| Hugo Go | Cold Build | 1m 20s | 1m 6s | 18% faster | 706.12 MB more (-240.01%) | BC used more storage; BC storage: remote CAS 746.62 MB, deps archive 253.70 MB |
| Immich | Cold Build | 5m 20s | 4m 49s | 10% faster | 7.76 GB (77.92%) | workflow total faster; BC storage: remote CAS 2.20 GB |
| Mastodon | Cold Build | 10m 8s | 9m 10s | 10% faster | 8.94 GB (89.75%) | workflow total faster; BC storage: remote CAS 1.02 GB |
| PostHog | Cold Build | 22m 9s | 15m 16s | 31% faster | 6.76 GB (51.23%) | workflow total faster; BC storage: remote CAS 6.43 GB |
| Storybook | Cold Build | 3m 26s | 3m 35s | 4% slower | 44.66 MB more (-6.12%) | warm, workflow total slower; BC used more storage; BC storage: deps archive 734.85 MB, runtime archive 39.79 MB |
| OpenTelemetry Java | Cold Build | 11m 21s | 11m 19s | near tie | 51.58 MB (6.11%) | warm slower; BC storage: deps archive 792.60 MB |
| Spring AI | Warm Build | 0m 44s | 0m 29s | 34% faster | 2.00 MB (0.21%) | cold, workflow total slower; BC storage: remote CAS 175.18 MB, deps archive 770.98 MB |
| gRPC | Cold Build | 25m 7s | 37m 1s | 47% slower | 648.07 MB more (-611.13%) | warm, workflow total slower; BC used more storage; BC storage: remote CAS 754.11 MB |
| Zed | Cold Build | 50m 15s | 41m 0s | 18% faster | 6.70 MB (0.24%) | workflow total faster; BC storage: remote CAS 2.04 GB, deps archive 753.56 MB |
| n8n | Workflow Total | 6m 4s | 5m 59s | near tie | 53.36 MB more (-7.12%) | BC used more storage; BC storage: remote CAS 37.79 MB, deps archive 701.30 MB, runtime archive 63.96 MB |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 56s | 2m 57s | near tie | 7.22 GB (95.6%) | BC storage: remote CAS 340.26 MB |
| Hugo Go | Workflow Total | 1m 9s | 0m 41s | 41% faster | 425.76 MB (18.43%) | commit build faster; BC storage: remote CAS 1.58 GB, deps archive 262.95 MB |
| Immich | Commit Build | 0m 13s | 0m 10s | near tie | 7.60 GB (77.56%) | tiny run; setup dominates; BC storage: remote CAS 2.20 GB |
| Mastodon | Commit Build | 0m 13s | 0m 16s | near tie | 8.94 GB (89.75%) | workflow total slower; tiny run; setup dominates; BC storage: remote CAS 1.02 GB |
| PostHog | Commit Build | 15m 35s | 11m 42s | 25% faster | 7.00 GB (53.23%) | workflow total faster; BC storage: remote CAS 6.15 GB |
| Storybook | Workflow Total | 1m 8s | 0m 54s | 21% faster | 1.11 GB (59.43%) | BC storage: deps archive 734.80 MB, runtime archive 39.79 MB |
| OpenTelemetry Java | Workflow Total | 2m 13s | 1m 35s | 29% faster | 3.02 GB (79.59%) | commit build faster; BC storage: deps archive 792.41 MB |
| Spring AI | Workflow Total | 1m 7s | 0m 45s | 33% faster | 2.39 GB (72.0%) | commit build faster; BC storage: remote CAS 180.74 MB, deps archive 770.98 MB |
| gRPC | Commit Build | 0m 54s | 0m 56s | near tie | 10.68 MB more (-1.36%) | BC used more storage; BC storage: remote CAS 798.03 MB |
| Zed | Workflow Total | 40m 40s | 37m 19s | 8% faster | 1.69 GB (14.81%) | BC storage: remote CAS 9.01 GB, deps archive 753.65 MB |
| n8n | Workflow Total | 2m 48s | 2m 31s | 10% faster | 3.08 GB (76.58%) | BC storage: remote CAS 199.20 MB, deps archive 701.70 MB, runtime archive 63.96 MB |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest complete same-commit AC/BC pair for each benchmark lane. The 3-pair rolling window lives separately in `data/latest/windows.json`, and commit-level pair evidence lives in `data/latest/pairs.json`. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are marked investigation-only.
