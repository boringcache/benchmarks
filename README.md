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

Generated: 2026-05-12 05:47 UTC

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
| Immich | Cold Build | 6m 28s | 4m 41s | 28% faster | 8.07 GB (78.58%) | mixed: warm slower; workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 13s | 9m 30s | 7% faster | 9.79 GB (90.56%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 3m 30s | 0m 15s | 93% faster | 5.91 GB (48.21%) | cold, workflow total faster; 3 paired samples |
| Storybook | Cold Build | 3m 47s | 3m 38s | 4% faster | 42.61 MB more (-5.83%) | BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 11m 15s | 11m 15s | near tie | 50.83 MB (6.03%) | warm slower; 3 paired samples |
| Spring AI | Warm Build | 0m 32s | 0m 30s | near tie | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 37m 15s | 34m 5s | 8% faster | 647.78 MB more (-611.22%) | mixed: warm slower; workflow total faster; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 53m 37s | 52m 44s | near tie | 6.23 MB (0.22%) | 3 paired samples |
| n8n | Warm Build | 1m 38s | 1m 9s | 30% faster | 52.92 MB more (-7.07%) | cold slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 53s | 2m 43s | 6% faster | 3.93 GB (92.2%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| Hugo Go | Commit Build | 0m 21s | 1m 2s | 200% slower | 72.42 MB more (-6.53%) | workflow total slower; BC used more storage; 3 paired samples |
| Immich | Commit Build | 8m 3s | 2m 28s | 69% faster | 8.30 GB (79.04%) | workflow total faster; 3 paired samples |
| Mastodon | Commit Build | 2m 59s | 2m 3s | 31% faster | 8.91 GB (89.71%) | workflow total faster; 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Workflow Total | 20m 12s | 14m 8s | 30% faster | 4.68 GB (42.81%) | commit build faster; 3 paired samples |
| Storybook | Commit Build | 1m 38s | 1m 57s | 20% slower | 1002.36 MB (56.45%) | workflow total slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 47s | 4m 43s | 164% slower | 2.10 GB (73.11%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 39s | 1m 43s | 163% slower | 2.39 GB (72.14%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 9m 3s | 13m 5s | 45% slower | 576.00 MB more (-95.71%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 23m 51s | 21m 51s | 8% faster | 6.28 GB (54.83%) | 3 paired samples |
| n8n | Commit Build | 3m 23s | 3m 29s | near tie | 1.44 GB (61.52%) | 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows use the latest 3 same-commit AC/BC pairs when enough samples are available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling Docker cache-bootstrap samples are excluded from comparative rows when steady samples exist.

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
