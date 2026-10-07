# Nightly CLI canary benchmarks

Each active benchmark repository runs `canary.yml` daily, staggered between
02:02 and 02:29 UTC. It selects the latest published CLI canary with a complete
set of release assets and dispatches its registered fresh workflows with that
exact `cli_version`. Archived repositories are excluded.

The dispatcher uses the repository's built-in `GITHUB_TOKEN` with Actions write
permission. A pinned shared action provides the dispatch code; it can request
runs only in the calling repository. Upstream synchronization keeps its existing
schedule. Benchmark workloads, source pins, installed tool versions, and stable
weekly runs keep their existing settings.

Each dispatch retains `nightly-canaries.json`, recording the exact CLI tag and
requested run IDs. The aggregate `Canary Benchmarks` workflow checks these
receipts hourly with its built-in token and read-only permissions. It reports
the latest dispatch and its exact workloads, including pending work, failures,
and cancellations. It fails for missing receipts, failed dispatches or workloads,
and dispatches more than 36 hours old. It never substitutes an older green run.
A successful dispatch means the requests were accepted; it does not mean the
benchmarks passed.

Start a repository's latest-canary run manually with:

```sh
gh workflow run canary.yml --repo boringcache/benchmark-hugo-go --ref main
```

For an exact canary tag, dispatch the existing fresh workflow with its
`cli_version` input. Preview the shared dispatcher without starting builds with:

```sh
ruby scripts/nightly-canaries.rb --repository boringcache/benchmark-hugo-go --dry-run
```

Inspect a failed or partial dispatch receipt before starting another run.
Rerunning a dispatch attempt is rejected to avoid duplicate builds.

Review the completed workload results and retained timing/memory evidence before
promoting a canary. Compare performance only with a stable run that used the
same workload source, tool versions, runner size, and cache state. The hourly
check reports execution failures; it is not an automatic slowdown threshold or
release-promotion gate.

An upstream tool upgrade needs its own candidate version in the benchmark.
For example, a Zed workflow pinned to sccache 0.17.0 cannot qualify sccache 0.18.0
by changing only the CLI tag. Keep customer-owned pins explicit, and run managed
BuildKit candidates through the existing `buildkit_image` input when qualifying
that image. Nightly CLI coverage does not imply coverage of every upstream release.
