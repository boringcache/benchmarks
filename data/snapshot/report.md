## Latest Benchmark Report

Generated: 2026-05-17 22:28 UTC

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

| Benchmark | Metric | actions/cache | BoringCache | Result | BC Storage Delta | Caveat |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold Build | 3m 13s | 3m 31s | 9% slower | 7.22 GB less (95.6%) | — |
| Hugo Go | Cold Build | 1m 20s | 1m 6s | 18% faster | 706.12 MB more (240.01%) | uses more storage |
| Immich | Cold Build | 5m 20s | 4m 49s | 10% faster | 7.76 GB less (77.92%) | — |
| Mastodon | Cold Build | 10m 8s | 9m 10s | 10% faster | 8.94 GB less (89.75%) | — |
| PostHog | Cold Build | 24m 10s | 15m 28s | 36% faster | 7.71 GB less (54.54%) | — |
| Storybook | Cold Build | 3m 26s | 3m 35s | 4% slower | 44.66 MB more (6.12%) | uses more storage |
| OpenTelemetry Java | Cold Build | 11m 21s | 11m 19s | near tie | 51.58 MB less (6.11%) | — |
| Spring AI | Warm Build | 0m 44s | 0m 29s | 34% faster | 2.00 MB less (0.21%) | — |
| gRPC | Cold Build | 25m 7s | 37m 1s | 47% slower | 648.07 MB more (611.13%) | uses more storage |
| Zed | Cold Build | 50m 15s | 41m 0s | 18% faster | 6.70 MB less (0.24%) | — |
| n8n | Workflow Total | 6m 4s | 5m 59s | near tie | 53.36 MB more (7.12%) | uses more storage |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | BC Storage Delta | Caveat |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 56s | 2m 57s | near tie | 7.22 GB less (95.6%) | — |
| Hugo Go | Workflow Total | 1m 9s | 0m 41s | 41% faster | 425.76 MB less (18.43%) | — |
| Immich | Commit Build | 0m 13s | 0m 10s | near tie | 7.60 GB less (77.56%) | — |
| Mastodon | Commit Build | 0m 13s | 0m 16s | near tie | 8.94 GB less (89.75%) | — |
| PostHog | Commit Build | 23m 26s | 11m 41s | 50% faster | 7.72 GB less (54.55%) | — |
| Storybook | Workflow Total | 1m 8s | 0m 54s | 21% faster | 1.11 GB less (59.43%) | — |
| OpenTelemetry Java | Workflow Total | 2m 13s | 1m 35s | 29% faster | 3.02 GB less (79.59%) | — |
| Spring AI | Workflow Total | 1m 7s | 0m 45s | 33% faster | 2.39 GB less (72.0%) | — |
| gRPC | Commit Build | 0m 54s | 0m 56s | near tie | 10.68 MB more (1.36%) | uses more storage |
| Zed | Workflow Total | 38m 39s | 38m 1s | near tie | 1.09 GB less (9.51%) | — |
| n8n | Workflow Total | 2m 48s | 2m 31s | 10% faster | 3.08 GB less (76.58%) | — |

Timing results use the selected headline metric for each lane and treat near ties as ties.

Rows use the latest complete same-commit AC/BC pair for each benchmark lane. The 3-pair rolling window lives separately in `data/latest/windows.json`, and commit-level pair evidence lives in `data/latest/pairs.json`. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are marked investigation-only.
