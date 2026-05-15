## Latest Benchmark Report

Generated: 2026-05-15 09:34 UTC

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
| Hugo | Cold Build | 3m 25s | 3m 22s | near tie | 6.47 GB (95.12%) | — |
| Hugo Go | Cold Build | 1m 15s | 1m 21s | 8% slower | 706.15 MB more (-240.02%) | workflow total slower; BC used more storage |
| Immich | Cold Build | 6m 40s | 4m 38s | 31% faster | 7.62 GB (77.61%) | workflow total faster |
| Mastodon | Warm Build | 0m 10s | 0m 9s | near tie | 8.95 GB (89.75%) | cold faster |
| PostHog | Cold Build | 19m 10s | 15m 56s | 17% faster | 10.27 GB (61.56%) | workflow total faster |
| Storybook | Warm Build | 4m 2s | 0m 42s | 83% faster | 44.61 MB more (-6.11%) | cold, workflow total faster; BC used more storage |
| OpenTelemetry Java | Cold Build | 11m 8s | 10m 47s | 3% faster | 51.45 MB (6.09%) | — |
| Spring AI | Warm Build | 0m 31s | 0m 26s | near tie | 2.00 MB (0.21%) | cold faster |
| gRPC | Cold Build | 37m 24s | 32m 28s | 13% faster | 648.34 MB more (-611.8%) | mixed: warm slower; workflow total faster; BC used more storage |
| Zed | Workflow Total | 53m 30s | 51m 46s | 3% faster | 6.26 MB (0.22%) | 2 paired samples |
| n8n | Cold Build | 5m 26s | 4m 56s | 9% faster | 52.89 MB more (-7.06%) | mixed: warm slower; workflow total faster; BC used more storage |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 11s | 0m 7s | near tie | 6.47 GB (95.12%) | tiny run; setup dominates |
| Hugo Go | Commit Build | 0m 30s | 0m 18s | 40% faster | 1.25 GB (56.12%) | workflow total faster; tiny run; setup dominates |
| Immich | Commit Build | 0m 16s | 0m 9s | 44% faster | 7.44 GB (77.2%) | workflow total faster; tiny run; setup dominates |
| Mastodon | Commit Build | 0m 28s | 0m 16s | 43% faster | 8.95 GB (89.75%) | workflow total faster; tiny run; setup dominates |
| PostHog | Commit Build | 19m 23s | 0m 19s | 98% faster | 10.27 GB (61.56%) | workflow total faster |
| Storybook | Workflow Total | 1m 17s | 0m 57s | 26% faster | 1.11 GB (59.43%) | — |
| OpenTelemetry Java | Workflow Total | 1m 55s | 1m 30s | 22% faster | 3.14 GB (80.2%) | — |
| Spring AI | Workflow Total | 0m 50s | 0m 42s | 16% faster | 2.39 GB (72.15%) | tiny run; setup dominates |
| gRPC | Commit Build | 0m 46s | 37m 30s | 4791% slower | 12.88 MB (1.65%) | workflow total slower |
| Zed | Workflow Total | 20m 42s | 19m 27s | 6% faster | 8.11 GB (70.9%) | commit build faster |
| n8n | Workflow Total | 1m 52s | 1m 28s | 21% faster | 2.92 GB (78.55%) | commit build faster |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.
