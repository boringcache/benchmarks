# BoringCache Benchmarks

This repo is the central aggregator for BoringCache benchmark data.

It does not own benchmark source trees, Dockerfiles, or benchmark execution for the
individual projects. Those live in standalone benchmark repos:

- `boringcache/benchmark-hugo`
- `boringcache/benchmark-immich`
- `boringcache/benchmark-mastodon`
- `boringcache/benchmark-posthog`
- `boringcache/benchmark-opentelemetry-java`
- `boringcache/benchmark-spring-ai`
- `boringcache/benchmark-grpc`
- `boringcache/benchmark-zed`
- `boringcache/benchmark-n8n`

Each benchmark repo:

- pins upstream source under `upstream/`
- owns its own upstream sync + AC/BC workflows
- uses real upstream sync commits to drive fresh (`cold` + `warm1`) and rolling commit-build comparisons
- publishes JSON benchmark artifacts

Docker benchmark rows measure BuildKit's outer registry cache path. They build the upstream Dockerfile unchanged and do not call `boringcache restore`, `boringcache save`, or `boringcache run` inside Dockerfile `RUN` steps. Public reporting is grounded on fresh cold-build plus warm-rerun lanes and rolling continuous-commit builds, with total workflow time included beside cold and warm timings. Rolling Docker import failures are investigation-only samples, not parity claims. The aggregate feed also suppresses incomplete storage probes instead of turning them into false savings rows.

This repo:

- fetches the latest successful benchmark artifacts from those standalone repos
- rebuilds `data/latest/index.json` from the latest complete same-commit AC/BC pair per benchmark lane
- writes commit-level pair evidence to `data/latest/pairs.json`
- writes rolling window summaries to `data/latest/windows.json`
- writes per-lane flow health to `data/latest/health.json`
- writes a generated markdown report under `data/latest/report.md`
- writes per-benchmark detail payloads under `data/latest/benchmarks/*.json`
- preserves the previous entry for a benchmark if that benchmark's latest fetch fails
- keeps `data/snapshot/` as the pinned public-site feed copied from a chosen `data/latest/` state

<!-- benchmark-report:start -->

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

<!-- benchmark-report:end -->

## Public copy guardrails

When benchmark data is used in public-facing copy:

- use the aggregate feed as the source of truth
- keep the claim anchored to the current fresh cold-build/warm-rerun comparison or rolling commit-build result
- keep mixed or negative results explicit
- do not promote incomplete benchmark entries in hero copy until the source workflow is fixed
- do not present rolling Docker import failures as parity wins
- keep storage savings alongside timing, especially when BoringCache wins on footprint more than wall clock

## Benchmark learning log

Durable benchmark and cache-behavior lessons are tracked in:

- `data/performance-learning-log.md`

Keep that log short. It should capture root causes, shipped fixes, and guardrails
worth preserving, not transient run status.

## Local Usage

Print reusable investigation tables from the current aggregate index:

```bash
ruby scripts/benchmark-table.rb --latest
```

Print just the raw timing/storage matrix:

```bash
ruby scripts/benchmark-table.rb --latest --format raw
```

Pull a specific GitHub Actions cohort by run id without rewriting website data:

```bash
ruby scripts/benchmark-table.rb \
  --pair posthog:fresh:24616102004:24616101993 \
  --pair posthog:rolling:24616102817:24616102999
```

Build a rolling investigation cohort from the latest three same-head-SHA AC/BC
pairs per benchmark/lane, then print averaged timing and storage. This is for
investigation; the public report uses the exact latest complete pair and writes
the rolling window separately to `data/latest/windows.json`:

```bash
ruby scripts/benchmark-cohort.rb --pairs 3
```

To inspect pair selection without downloading artifacts:

```bash
ruby scripts/benchmark-cohort.rb --pairs 3 --cohort-only
```

For larger investigations, keep a JSON or YAML cohort file with `pairs`:

```json
{
  "pairs": [
    { "benchmark": "posthog", "lane": "fresh", "actions_cache": 24616102004, "boringcache": 24616101993 },
    { "benchmark": "posthog", "lane": "rolling", "actions_cache": 24616102817, "boringcache": 24616102999 }
  ]
}
```

Then run:

```bash
ruby scripts/benchmark-table.rb --cohort /path/to/cohort.json --output-md /tmp/benchmark-report.md
```

Regenerate the latest index locally:

```bash
ruby scripts/publish-index.rb
```

Check a downloaded release-path proof bundle before using it for launch claims:

```bash
ruby scripts/launch-proof.rb \
  --artifacts /path/to/downloaded/benchmark-artifacts \
  --diagnostics /path/to/downloaded/diagnostics \
  --matrix config/launch-proof-matrix.json \
  --evidence /path/to/launch-proof-evidence.json \
  --action-ref boringcache/one@v1
```

The proof gate checks product refs, cache mode/lane, sample classification, and
the matrix coverage needed for release claims. Evidence manifests use stable path
labels, so failures say which proof item is missing.

An abbreviated example manifest lives at `config/launch-proof-evidence.example.json`.
Validate the proof gate itself with:

```bash
ruby test/launch_proof_test.rb
```

Pin the current generated aggregate as the public snapshot:

```bash
ruby scripts/pin-snapshot.rb
```

Both scripts expect GitHub CLI authentication when they need to read workflow runs and
artifacts from the standalone benchmark repos. `publish-index.rb` refreshes
`data/latest/report.md` and the generated report section in this README.
`pin-snapshot.rb` is local-only and copies the current generated aggregate into
`data/snapshot/` for the public site;
`benchmark-table.rb` is read-only unless `--output-md` or `--output-json` is passed.
