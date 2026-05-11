## Latest Benchmark Report

Generated: 2026-05-11 17:21 UTC

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
| Hugo | Cold Build | 3m 29s | 3m 24s | near tie | 4.10 GB (92.51%) | 3 paired samples |
| Hugo Go | Cold Build | 1m 19s | 1m 22s | 3% slower | 621.95 MB more (-211.74%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Warm Build | 0m 20s | 0m 13s | 32% faster | 7.53 GB (77.4%) | cold, workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 13s | 9m 30s | 7% faster | 9.79 GB (90.56%) | workflow total faster; 3 paired samples |
| PostHog | Cold Build | 23m 29s | 16m 21s | 30% faster | 5.15 GB (44.78%) | mixed: warm slower; workflow total faster; 3 paired samples |
| Storybook | Cold Build | 3m 47s | 3m 38s | 4% faster | 42.61 MB more (-5.83%) | BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 11m 15s | 11m 15s | near tie | 50.83 MB (6.03%) | warm slower; 3 paired samples |
| Spring AI | Warm Build | 0m 32s | 0m 30s | near tie | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 32m 45s | 34m 8s | 4% slower | 647.73 MB more (-611.07%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Zed | Cold Build | 51m 56s | 47m 42s | 8% faster | 6.09 MB (0.21%) | mixed: warm slower; workflow total faster; 3 paired samples |
| n8n | Cold Build | 5m 26s | 5m 37s | 3% slower | 52.81 MB more (-7.05%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 53s | 2m 43s | 6% faster | 3.93 GB (92.2%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 1m 2s | 200% slower | 72.42 MB more (-6.53%) | workflow total slower; BC used more storage; 3 paired samples |
| Immich | Commit Build | 4m 14s | 2m 21s | 44% faster | 7.47 GB (77.25%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Mastodon | Commit Build | 2m 59s | 2m 3s | 31% faster | 8.91 GB (89.71%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Commit Build | 28m 44s | 9m 21s | 67% faster | 5.91 GB (48.78%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Storybook | Commit Build | 1m 38s | 1m 57s | 20% slower | 1002.36 MB (56.45%) | workflow total slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 47s | 4m 43s | 164% slower | 2.10 GB (73.11%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 39s | 1m 43s | 163% slower | 2.39 GB (72.14%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 2m 35s | 13m 27s | 420% slower | 391.60 MB more (-79.52%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Commit Build | 31m 29s | 39m 35s | 26% slower | 4.34 GB (37.9%) | workflow total slower; 3 paired samples |
| n8n | Commit Build | 3m 49s | 3m 39s | 5% faster | 1.34 GB (61.74%) | workflow total faster; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
