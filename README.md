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
- uses real upstream sync commits to drive fresh (`cold` + `warm1`) and rolling (first-build) comparisons
- publishes JSON benchmark artifacts

Docker benchmark rows measure BuildKit's outer registry cache path. They build the upstream Dockerfile unchanged and do not call `boringcache restore`, `boringcache save`, or `boringcache run` inside Dockerfile `RUN` steps. Public reporting is grounded on fresh isolated lanes and rolling continuous-commit first builds, with total workflow time included beside cold and warm timings. Rolling Docker import failures are investigation-only samples, not parity claims. The aggregate feed also suppresses incomplete storage probes instead of turning them into false savings rows.

This repo:

- fetches the latest successful benchmark artifacts from those standalone repos
- rebuilds one aggregate `data/latest/index.json` with one entry per benchmark
- writes a generated markdown report under `data/latest/report.md`
- writes per-benchmark detail payloads under `data/latest/benchmarks/*.json`
- averages the latest three same-commit AC/BC pairs per benchmark lane when enough samples are available
- preserves the previous entry for a benchmark if that benchmark's latest fetch fails
- keeps `data/snapshot/` as the pinned public-site feed copied from a chosen `data/latest/` state

<!-- benchmark-report:start -->

## Latest Benchmark Report

Generated: 2026-05-05 20:05 UTC

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
| Hugo | Warm | 0m 14s | 0m 8s | 44% faster | 8.95 GB (96.42%) | cold faster; 3 paired samples |
| Immich | Cold | 5m 51s | 5m 5s | 13% faster | 8.31 GB (78.55%) | run total faster; 3 paired samples |
| Mastodon | Cold | 10m 54s | 9m 28s | 13% faster | 9.82 GB (90.66%) | run total faster; 3 paired samples |
| PostHog | Cold | 22m 51s | 15m 39s | 32% faster | 5.45 GB (47.24%) | run total faster; 3 paired samples |
| OpenTelemetry Java | Cold | 10m 51s | 10m 44s | near tie | 50.41 MB (6.11%) | warm, run total slower; 3 paired samples |
| Spring AI | Cold | 4m 29s | 4m 40s | 4% slower | 165.61 MB more (-17.07%) | run total slower; BC used more storage; 3 paired samples |
| gRPC | Cold | 35m 25s | 34m 16s | 3% faster | 496.10 MB more (-185.37%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Cold | 50m 16s | 49m 57s | near tie | — | warm, run total slower; storage unavailable; 3 paired samples |
| n8n | Cold | 5m 21s | 5m 41s | 6% slower | 16.48 MB more (-2.39%) | warm, run total slower; BC used more storage; 3 paired samples |

### Rolling Historical

| Benchmark | Headline | actions/cache | BoringCache | Result | Storage Saved | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | First Build | 2m 10s | 3m 16s | reseeded 3/3 | 9.04 GB (96.46%) | 3 paired samples; BC reseeded 3/3; BC cache import proxy_unreadable; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Immich | First Build | 1m 41s | 3m 24s | reseeded 2/3 | 7.44 GB (76.61%) | 3 paired samples; BC reseeded 2/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| Mastodon | First Build | 5m 34s | 4m 56s | reseeded 3/3 | 9.39 GB (90.27%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| PostHog | First Build | 15m 30s | 11m 12s | reseeded 3/3 | 4.94 GB (45.81%) | 3 paired samples; BC reseeded 3/3; Rolling Docker reseeds are first-build investigation samples, not steady-state parity. |
| OpenTelemetry Java | Cold | 3m 19s | 4m 48s | 45% slower | 1.91 GB (71.6%) | run total slower; 3 paired samples |
| Spring AI | Cold | 2m 24s | 2m 53s | 20% slower | 1.71 GB (53.25%) | run total slower; 3 paired samples |
| gRPC | Cold | 0m 38s | 2m 22s | 270% slower | 292.30 MB more (-47.46%) | run total slower; BC used more storage; 3 paired samples |
| Zed | Cold | 25m 27s | 41m 51s | 64% slower | 1.12 GB more (-12.03%) | run total slower; BC used more storage; 3 paired samples |
| n8n | Run Total | 4m 47s | 3m 53s | 19% faster | 7.09 GB (91.15%) | 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker reseeds or cache-import misses render as investigation-only.

<!-- benchmark-report:end -->

## Public copy guardrails

When benchmark data is used in public-facing copy:

- use the aggregate feed as the source of truth
- keep the claim anchored to the current fresh cold/warm comparison or rolling first-build result
- keep mixed or negative results explicit
- do not promote incomplete benchmark entries in hero copy until the source workflow is fixed
- do not present rolling Docker import failures as parity wins
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

Build a rolling investigation cohort from the latest three same-head-SHA AC/BC
pairs per benchmark/lane, then print averaged timing and storage:

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

The proof gate requires BoringCache artifacts to carry product refs, cache
mode/lane, sample classification, Docker OCI counters where applicable, and
`cache_session_summary` evidence from either embedded artifact JSON or attached
request-metrics/status diagnostics. With `--matrix`, it also requires explicit
tool/surface/scenario coverage for CLI and action paths across archive, Docker,
sccache, Go, Bazel, Gradle, Maven, Turbo, and Nx. The same matrix is now the
launch-readiness gate for the P0 product paths: cache lifecycle retirement and
cleanup, v2 save pressure, PR/main trust scopes, proxy readiness, auth and CLI
token onboarding, billing quotas, diagnostics, and the new-user first-cache
flow.

Evidence manifests use stable path labels, so the failure says exactly what is
missing. Each evidence item must carry released product refs and the concrete
fields required by its matrix row:

```json
{
  "evidence": [
    {
      "tool": "docker",
      "surface": "action",
      "scenario": "fresh_runner_rerun",
      "status": "pass",
      "product_refs": {
        "action_ref": "boringcache/one@v1",
        "action_sha": "0123456789abcdef0123456789abcdef01234567",
        "cli_version": "v1.12.86",
        "web_revision": "89abcdef0123456789abcdef0123456789abcdef",
        "api_url": "https://app.boringcache.com"
      },
      "workspace": "acme/web",
      "cache_tag": "docker-default-main",
      "run_uid": "gh-1234567890-1",
      "mode": "docker",
      "adapter": "oci",
      "restore_result": "hit",
      "save_result": "published",
      "new_blob_count": 0,
      "remote_fetches": 12,
      "publish_status": "complete",
      "session_summary": { "schema": "cache_session_summary.v2" },
      "reporting_url": "https://app.boringcache.com/workspaces/acme/web/cache/sessions/abc123",
      "run_url": "https://github.com/boringcache/benchmark-hugo/actions/runs/123",
      "artifact": "benchmark-hugo-boringcache-fresh.json"
    }
  ]
}
```

The launch matrix distinguishes cold fresh runs, same-runner reruns,
fresh-runner reruns, repeat fresh-after-purge runs, Docker continuous rolling
first-builds, Docker same-alias two-writer proof, cleanup interruption recovery,
quota enforcement, save hot-path pressure, PR/fork trust cases, auth/billing
controls, and customer-safe diagnostics. That prevents a single warm sample or
local test from standing in for released-path evidence.

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
