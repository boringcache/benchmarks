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

Generated: 2026-04-15 20:06 UTC

### Lane Coverage

| Benchmark | Fresh | Rolling |
| --- | --- | --- |
| Hugo | yes | yes |
| Immich | yes | yes |
| Mastodon | yes | yes |
| PostHog | yes | yes |
| OpenTelemetry Java | yes | — |
| Spring AI | yes | yes |
| gRPC | yes | yes |
| Zed | yes | — |
| n8n | yes | yes |

### Fresh Isolated

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Warm | 0m 3s | 0m 2s | near tie | 8.65 GB (87.17%) | cold, layer miss, run total faster |
| Immich | Cold | 17m 38s | 15m 57s | 10% faster | 27.84 GB (87.11%) | mixed: warm slower; layer miss, run total faster |
| Mastodon | Run Total | 11m 29s | 9m 25s | 18% faster | 13.27 GB (87.33%) | cold, layer miss faster |
| PostHog | Cold | 19m 1s | 13m 28s | 29% faster | 20.18 GB (64.16%) | mixed: warm slower; layer miss, run total faster |
| OpenTelemetry Java | Cold | 10m 22s | 10m 58s | 6% slower | 49.38 MB (6.05%) | warm, run total slower |
| Spring AI | Cold | 3m 35s | 4m 39s | 30% slower | 4.39 MB (0.44%) | run total slower |
| gRPC | Cold | 37m 8s | 39m 10s | 5% slower | 366.15 MB (100.0%) | warm, run total slower |
| Zed | Cold | 49m 23s | 49m 13s | near tie | 2.07 GB (74.88%) | run total slower |
| n8n | Cold | 8m 7s | 5m 14s | 36% faster | 16.70 MB more (-2.56%) | run total faster; BC used more storage |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Run Total | 2m 48s | 1m 28s | 48% faster | 10.36 GB (89.06%) | mixed: cold, warm slower; layer miss faster |
| Immich | Run Total | 12m 20s | 6m 52s | 44% faster | 25.59 GB (85.37%) | mixed: cold slower; layer miss faster |
| Mastodon | Run Total | 8m 36s | 3m 48s | 56% faster | 14.58 GB (86.27%) | mixed: cold slower; layer miss faster |
| PostHog | Cold | 11m 34s | 13m 7s | 13% slower | 15.01 GB (50.37%) | mixed: warm, run total slower; layer miss faster |
| OpenTelemetry Java | — | — | — | — | — | not published yet |
| Spring AI | Cold | 0m 22s | 0m 19s | near tie | 994.44 MB (50.22%) | run total slower |
| gRPC | Cold | 37m 40s | 26m 51s | 29% faster | 366.21 MB (100.0%) | mixed: warm slower; run total faster |
| Zed | — | — | — | — | — | not published yet |
| n8n | Cold | 0m 44s | 0m 46s | near tie | 639.56 MB (48.97%) | run total slower |

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

## Local Usage

Regenerate the latest index locally:

```bash
ruby scripts/publish-index.rb
```

The script expects GitHub CLI authentication that can read workflow runs and artifacts
from the standalone benchmark repos. It also refreshes `data/latest/report.md` and the
generated report section in this README.
