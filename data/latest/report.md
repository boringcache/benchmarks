## Latest Benchmark Report

Generated: 2026-05-11 13:33 UTC

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
| Hugo | Cold Build | 3m 24s | 3m 26s | near tie | 3.76 GB (91.88%) | workflow total slower; 3 paired samples |
| Hugo Go | Cold Build | 1m 19s | 1m 20s | near tie | 537.23 MB more (-182.86%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Cold Build | 5m 9s | 4m 42s | 9% faster | 8.12 GB (78.7%) | workflow total faster; 3 paired samples |
| Mastodon | Warm Build | 0m 16s | 0m 12s | near tie | 9.96 GB (90.7%) | cold, workflow total faster; 3 paired samples |
| PostHog | Cold Build | 21m 46s | 19m 37s | 10% faster | 6.69 GB (51.65%) | mixed: warm slower; workflow total faster; 3 paired samples |
| Storybook | Cold Build | 3m 33s | 3m 39s | near tie | 42.59 MB more (-5.83%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Warm Build | 1m 6s | 1m 2s | 5% faster | 50.73 MB (6.02%) | cold, workflow total slower; 3 paired samples |
| Spring AI | Cold Build | 3m 59s | 4m 6s | near tie | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 35m 25s | 34m 10s | 4% faster | 647.71 MB more (-611.02%) | mixed: warm slower; workflow total faster; BC used more storage; 3 paired samples |
| Zed | Cold Build | 49m 59s | 44m 35s | 11% faster | 6.14 MB (0.22%) | workflow total faster; 3 paired samples |
| n8n | Cold Build | 5m 23s | 5m 19s | near tie | 40.42 MB more (-5.4%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 53s | 2m 47s | 3% faster | 3.76 GB (91.88%) | 3 paired samples |
| Hugo Go | Commit Build | 0m 21s | 1m 3s | 194% slower | 116.84 MB more (-11.91%) | workflow total slower; BC used more storage; 3 paired samples |
| Immich | Commit Build | 3m 10s | 1m 19s | 59% faster | 7.83 GB (78.09%) | workflow total faster; 3 paired samples |
| Mastodon | Commit Build | 2m 18s | 1m 45s | 24% faster | 8.96 GB (89.77%) | workflow total faster; 3 paired samples |
| PostHog | Commit Build | 22m 19s | 12m 40s | 43% faster | 6.13 GB (49.5%) | workflow total faster; 3 paired samples |
| Storybook | Workflow Total | 2m 1s | 1m 59s | near tie | 985.76 MB (56.04%) | commit build slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 19s | 4m 37s | 249% slower | 2.10 GB (73.1%) | workflow total slower; 3 paired samples |
| Spring AI | Workflow Total | 1m 16s | 0m 52s | 32% faster | 2.39 GB (72.14%) | commit build faster; 3 paired samples |
| gRPC | Commit Build | 9m 7s | 8m 55s | near tie | 504.01 MB more (-112.08%) | BC used more storage; 3 paired samples |
| Zed | Workflow Total | 20m 59s | 20m 48s | near tie | 3.07 GB more (-26.85%) | commit build slower; BC used more storage; 3 paired samples |
| n8n | Commit Build | 4m 8s | 4m 25s | 7% slower | 1.11 GB (57.56%) | workflow total slower; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.
