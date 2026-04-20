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
- uses real upstream sync commits to drive cold + warm comparisons
- publishes JSON benchmark artifacts

Docker benchmark rows measure BuildKit's outer registry cache path. They build the upstream Dockerfile unchanged and do not call `boringcache restore`, `boringcache save`, or `boringcache run` inside Dockerfile `RUN` steps. A `layer_miss` scenario means no imported Docker layer cache on a fresh runner; upstream Dockerfile cache mounts stay native to BuildKit.

This repo:

- fetches the latest successful benchmark artifacts from those standalone repos
- rebuilds one aggregate `data/latest/index.json` with one entry per benchmark
- writes a generated markdown report under `data/latest/report.md`
- writes per-benchmark detail payloads under `data/latest/benchmarks/*.json`
- keeps one latest paired entry per benchmark so the aggregate feed stays stable even when source repos sync often
- preserves the previous entry for a benchmark if that benchmark's latest fetch fails
- serves as the central website/index feed

<!-- benchmark-report:start -->

## Latest Benchmark Report

Generated: 2026-04-19 05:32 UTC

### Lane Coverage

| Benchmark | Fresh | Rolling |
| --- | --- | --- |
| Hugo | yes | yes |
| Immich | yes | yes |
| Mastodon | yes | yes |
| PostHog | yes | yes |
| OpenTelemetry Java | yes | yes |
| Spring AI | yes | yes |
| gRPC | yes | yes |
| Zed | yes | yes |
| n8n | yes | yes |

### Fresh Isolated

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Run Total | 4m 25s | 3m 48s | 14% faster | 19.32 GB (93.82%) | cold, layer miss faster |
| Immich | Cold | 16m 35s | 16m 1s | 3% faster | 27.61 GB (87.06%) | layer miss faster |
| Mastodon | Warm | 0m 12s | 0m 9s | near tie | 28.73 GB (93.72%) | cold, layer miss, run total faster |
| PostHog | Cold | 21m 58s | 13m 15s | 40% faster | 19.67 GB (64.37%) | layer miss, run total faster |
| OpenTelemetry Java | Cold | 8m 31s | 10m 42s | 26% slower | 49.28 MB (6.04%) | warm, run total slower |
| Spring AI | Cold | 4m 23s | 4m 6s | 6% faster | 3.59 MB (0.36%) | run total faster |
| gRPC | Cold | 32m 6s | 38m 5s | 19% slower | 362.66 MB (100.0%) | warm, run total slower |
| Zed | Warm | 18m 23s | 17m 50s | near tie | 2.08 GB (74.99%) | — |
| n8n | Warm | 1m 7s | 1m 0s | 10% faster | 16.73 MB more (-2.56%) | run total slower; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Cold | 3m 43s | 1m 5s | 71% faster | 18.10 GB (91.91%) | run total faster |
| Immich | Run Total | 0m 32s | 0m 20s | 38% faster | 25.49 GB (85.38%) | cold faster; tiny run; setup dominates |
| Mastodon | Run Total | 0m 28s | 0m 20s | 29% faster | 28.07 GB (93.58%) | tiny run; setup dominates |
| PostHog | Cold | 10m 55s | 12m 14s | 12% slower | 9.55 GB (31.85%) | — |
| OpenTelemetry Java | Cold | 0m 45s | 1m 4s | 42% slower | 939.33 MB (55.07%) | run total slower |
| Spring AI | Cold | 0m 31s | 0m 34s | near tie | 1.30 GB (57.47%) | run total slower |
| gRPC | Cold | 36m 50s | 24m 51s | 33% faster | 37.36 MB (3.32%) | run total faster |
| Zed | Cold | 17m 32s | 17m 48s | near tie | 10.70 GB (93.92%) | — |
| n8n | Cold | 1m 8s | 1m 12s | 6% slower | 1.12 GB (63.32%) | run total slower |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rolling shows the latest successful paired rolling lane when it has been published. A blank row means that lane has not landed yet in the aggregate feed.

<!-- benchmark-report:end -->

## Public copy guardrails

When benchmark data is used in public-facing copy:

- use the aggregate feed as the source of truth
- keep the claim anchored to the current cold or warm comparison
- keep mixed or negative results explicit
- do not promote incomplete benchmark entries in hero copy until the source workflow is fixed
- keep storage savings alongside timing, especially when BoringCache wins on footprint more than wall clock

## Engineering learning log

Performance and stability learnings are tracked in:

- `data/performance-learning-log.md`

Update this log when a benchmark regression is root-caused, when a cache behavior
contract changes, or when a workflow knob is added/removed for fairness.

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

Both scripts expect GitHub CLI authentication when they need to read workflow runs and
artifacts from the standalone benchmark repos. `publish-index.rb` refreshes
`data/latest/report.md` and the generated report section in this README;
`benchmark-table.rb` is read-only unless `--output-md` or `--output-json` is passed.
