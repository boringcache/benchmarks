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

Generated: 2026-05-09 20:47 UTC

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
| Hugo | Cold Build | 3m 36s | 3m 21s | 7% faster | 3.41 GB (91.12%) | workflow total faster; 3 paired samples |
| Hugo Go | Cold Build | 1m 21s | 1m 20s | near tie | 452.52 MB more (-153.98%) | warm, workflow total slower; BC used more storage; 3 paired samples |
| Immich | Cold Build | 5m 9s | 4m 40s | 10% faster | 7.99 GB (78.42%) | mixed: warm slower; workflow total faster; 3 paired samples |
| Mastodon | Cold Build | 10m 11s | 9m 20s | 8% faster | 9.22 GB (90.03%) | workflow total faster; 3 paired samples |
| PostHog | Warm Build | 3m 17s | 0m 11s | 94% faster | 7.01 GB (52.46%) | cold, workflow total faster; 3 paired samples |
| Storybook | Warm Build | 0m 51s | 0m 46s | 10% faster | 43.81 MB more (-5.99%) | cold, workflow total faster; BC used more storage; 3 paired samples |
| OpenTelemetry Java | Cold Build | 10m 21s | 11m 31s | 11% slower | 50.64 MB (6.01%) | warm, workflow total slower; 3 paired samples |
| Spring AI | Warm Build | 0m 30s | 0m 28s | near tie | 1.38 MB (0.15%) | workflow total slower; 3 paired samples |
| gRPC | Cold Build | 35m 56s | 35m 30s | near tie | 647.83 MB more (-611.38%) | warm slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 53m 0s | 51m 51s | near tie | 2.04 GB (73.48%) | 3 paired samples |
| n8n | Cold Build | 5m 21s | 5m 46s | 8% slower | 15.53 MB more (-2.07%) | warm, workflow total slower; BC used more storage; 3 paired samples |

### Rolling

| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Hugo | Commit Build | 2m 13s | 3m 26s | cache import unavailable | 3.41 GB (91.12%) | 3 paired samples; BC cache import proxy_unreadable; Rolling cache import was unavailable, so this sample populated the rolling cache and is excluded from parity claims. |
| Hugo Go | Commit Build | 0m 21s | 1m 4s | 206% slower | 169.64 MB (18.52%) | workflow total slower; 3 paired samples |
| Immich | Commit Build | 0m 9s | 0m 10s | near tie | 7.48 GB (77.28%) | tiny run; setup dominates; 3 paired samples |
| Mastodon | Commit Build | 1m 14s | 1m 7s | 9% faster | 8.94 GB (89.75%) | 2 steady samples; 1/3 bootstrap samples excluded |
| PostHog | Commit Build | 21m 31s | 8m 9s | 62% faster | 6.46 GB (51.56%) | workflow total faster; 3 paired samples |
| Storybook | Commit Build | 1m 42s | 2m 44s | 61% slower | 893.13 MB (53.55%) | workflow total slower; 3 paired samples |
| OpenTelemetry Java | Commit Build | 1m 19s | 4m 32s | 243% slower | 2.09 GB (73.01%) | workflow total slower; 3 paired samples |
| Spring AI | Commit Build | 0m 51s | 3m 12s | 276% slower | 2.39 GB (72.14%) | workflow total slower; 3 paired samples |
| gRPC | Commit Build | 3m 44s | 14m 43s | 293% slower | 413.52 MB more (-112.41%) | workflow total slower; BC used more storage; 3 paired samples |
| Zed | Workflow Total | 35m 1s | 34m 39s | near tie | 10.71 GB (93.57%) | 3 paired samples |
| n8n | Commit Build | 1m 47s | 3m 24s | 90% slower | 1.05 GB (58.5%) | workflow total slower; 3 paired samples |

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
