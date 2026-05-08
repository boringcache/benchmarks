## Latest Benchmark Report

Generated: 2026-05-08 13:02 UTC

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
| Hugo | Cold Build | 3m 31s | 3m 27s | near tie | 3.72 GB (91.79%) | 3 paired samples |
| Hugo Go | Cold Build | 1m 21s | 1m 20s | near tie | 452.48 MB more (-153.92%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Cold Build | 6m 43s | 4m 48s | 29% faster | 7.43 GB (77.17%) | workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 9s | 9m 23s | 8% faster | 9.51 GB (90.3%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 3m 23s | 0m 14s | 93% faster | 4.22 GB (40.16%) | cold, workflow total faster; 3 paired samples |
| Storybook | Cold Build | 3m 32s | 5m 7s | 45% slower | 43.66 MB more (-5.97%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 10m 47s | 11m 24s | 6% slower | 50.59 MB (6.08%) | warm, workflow total slower; 3 paired samples |
| Spring AI | Warm Build | 0m 31s | 0m 29s | near tie | 1.39 MB (0.15%) | cold, workflow total slower; 3 paired samples |
| gRPC | Cold Build | 33m 45s | 33m 44s | near tie | 500.38 MB more (-314.24%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 53m 28s | 51m 20s | 4% faster | 2.04 GB (73.46%) | warm faster; 3 paired samples |
| n8n | Cold Build | 5m 30s | 5m 30s | near tie | 15.62 MB more (-2.13%) | warm slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 0m 9s | 0m 11s | near tie | 4.61 GB (93.29%) | workflow total slower; tiny run; setup dominates; 1 steady samples; 2/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 22s | 0m 54s | 149% slower | 204.95 MB (21.54%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 3m 56s | 4m 38s | 18% slower | 7.24 GB (76.71%) | workflow total slower; 2 steady samples; 1/3 bootstrap samples excluded |
| Mastodon | Commit Build | 2m 12s | 1m 58s | 11% faster | 8.93 GB (89.74%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Commit Build | 17m 45s | 11m 43s | 34% faster | 7.68 GB (56.03%) | workflow total faster; 3 paired samples |
| Storybook | Workflow Total | 4m 23s | 4m 12s | 4% faster | 822.89 MB (51.32%) | commit build faster; 3 paired samples |
| OpenTelemetry Java | Commit Build | 2m 6s | 7m 44s | 269% slower | 1.87 GB (70.98%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 57s | 3m 15s | 245% slower | 2.39 GB (72.14%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 2m 43s | 23m 9s | 751% slower | 349.09 MB more (-71.49%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Commit Build | 38m 51s | 39m 44s | near tie | 8.93 GB (92.39%) | 3 paired samples |
| n8n | Commit Build | 2m 41s | 3m 18s | 23% slower | 774.88 MB (50.8%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
