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
- rebuilds one aggregate `data/latest/index.json` with one entry per benchmark
- writes a generated markdown report under `data/latest/report.md`
- writes per-benchmark detail payloads under `data/latest/benchmarks/*.json`
- averages the latest three same-commit AC/BC pairs per benchmark lane when enough samples are available
- preserves the previous entry for a benchmark if that benchmark's latest fetch fails
- keeps `data/snapshot/` as the pinned public-site feed copied from a chosen `data/latest/` state

<!-- benchmark-report:start -->

## Latest Benchmark Report

Generated: 2026-05-16 16:49 UTC

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
| Hugo | Cold Build | 3m 26s | 3m 21s | near tie | 7.75 GB (95.89%) | BC storage: remote CAS 340.26 MB; 2 paired samples |
| Hugo Go | Cold Build | 1m 20s | 1m 6s | 18% faster | 706.12 MB more (-240.01%) | BC used more storage; BC storage: remote CAS 746.62 MB, deps archive 253.70 MB |
| Immich | Cold Build | 5m 24s | 4m 28s | 17% faster | 8.22 GB (78.9%) | workflow total faster; BC storage: remote CAS 2.20 GB; 3 paired samples |
| Mastodon | Cold Build | 10m 8s | 9m 10s | 10% faster | 8.94 GB (89.75%) | workflow total faster; BC storage: remote CAS 1.02 GB |
| PostHog | Cold Build | 25m 48s | 15m 32s | 40% faster | 8.31 GB (56.39%) | workflow total faster; BC storage: remote CAS 6.43 GB; 3 paired samples |
| Storybook | Cold Build | 3m 26s | 3m 35s | 4% slower | 44.66 MB more (-6.12%) | warm, workflow total slower; BC used more storage; BC storage: deps archive 734.85 MB, runtime archive 39.79 MB |
| OpenTelemetry Java | Cold Build | 11m 21s | 11m 19s | near tie | 51.58 MB (6.11%) | warm slower; BC storage: deps archive 792.60 MB |
| Spring AI | Warm Build | 0m 44s | 0m 29s | 34% faster | 2.00 MB (0.21%) | cold, workflow total slower; BC storage: remote CAS 175.18 MB, deps archive 770.98 MB |
| gRPC | Cold Build | 31m 42s | 34m 56s | 10% slower | 648.06 MB more (-611.07%) | warm, workflow total slower; BC used more storage; BC storage: remote CAS 754.11 MB; 2 paired samples |
| Zed | Warm Build | 18m 3s | 18m 1s | near tie | 5.90 MB (0.21%) | cold slower; BC storage: remote CAS 2.04 GB, deps archive 753.56 MB; 3 paired samples |
| n8n | Workflow Total | 5m 59s | 5m 47s | 3% faster | 53.33 MB more (-7.11%) | warm slower; BC used more storage; BC storage: remote CAS 37.79 MB, deps archive 701.29 MB, runtime archive 63.96 MB; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 1m 27s | 1m 31s | 5% slower | 7.75 GB (95.89%) | workflow total slower; BC storage: remote CAS 340.26 MB; 2 paired samples |
| Hugo Go | Workflow Total | 1m 16s | 0m 50s | 34% faster | 861.66 MB (35.14%) | commit build faster; BC storage: remote CAS 1.30 GB, deps archive 262.95 MB; 2 paired samples |
| Immich | Commit Build | 1m 19s | 1m 11s | 10% faster | 7.42 GB (77.15%) | workflow total faster; BC storage: remote CAS 2.20 GB; 3 paired samples |
| Mastodon | Commit Build | 0m 13s | 0m 16s | near tie | 8.94 GB (89.75%) | workflow total slower; tiny run; setup dominates; BC storage: remote CAS 1.02 GB |
| PostHog | Commit Build | 18m 19s | 9m 44s | 47% faster | 6.57 GB (50.94%) | workflow total faster; BC storage: remote CAS 6.33 GB; 3 paired samples |
| Storybook | Workflow Total | 1m 8s | 0m 54s | 21% faster | 1.11 GB (59.43%) | BC storage: deps archive 734.80 MB, runtime archive 39.79 MB |
| OpenTelemetry Java | Workflow Total | 2m 13s | 1m 35s | 29% faster | 3.02 GB (79.59%) | commit build faster; BC storage: deps archive 792.41 MB |
| Spring AI | Workflow Total | 1m 7s | 0m 45s | 33% faster | 2.39 GB (72.0%) | commit build faster; BC storage: remote CAS 180.74 MB, deps archive 770.98 MB |
| gRPC | Commit Build | 0m 46s | 19m 21s | 2424% slower | 10.66 MB more (-1.35%) | workflow total slower; BC used more storage; BC storage: remote CAS 798.03 MB; 2 paired samples |
| Zed | Workflow Total | 34m 18s | 32m 56s | 4% faster | 4.32 GB (37.78%) | BC storage: remote CAS 6.37 GB, deps archive 753.41 MB; 3 paired samples |
| n8n | Workflow Total | 2m 7s | 1m 52s | 12% faster | 3.08 GB (76.61%) | commit build faster; BC storage: remote CAS 197.45 MB, deps archive 701.70 MB, runtime archive 63.96 MB; 3 paired samples |

Result is signed and near-tie aware, so tiny no-op runs do not get flattened into misleading 0% rows.

Rows prefer the latest BoringCache product cohort for same-commit AC/BC pairs, then use up to 3 steady samples when available. Artifact classification is the source of truth: invalid fresh warm imports are withheld from parity claims, and rolling cache-bootstrap samples are excluded from comparative rows when steady samples exist.

<!-- benchmark-report:end -->

## Public copy guardrails

When benchmark data is used in public-facing copy:

- use the aggregate feed as the source of truth
- keep the claim anchored to the current fresh cold-build/warm-rerun comparison or rolling commit-build result
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
commit builds, Docker same-alias two-writer proof, cleanup interruption recovery,
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
