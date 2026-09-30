# Nightly CLI canary benchmarks

At 02:17 UTC, `Canary Benchmarks` selects the latest published CLI canary and
dispatches each distinct fresh workflow in the benchmark registry. It uses the
existing `cli_version` input and standard runners. It does not rebuild the CLI,
change benchmark source pins, or change the installed build-tool versions.

The dispatch receipt records the exact CLI tag and every requested run. An hourly
check reports those run IDs, including failures, cancellations, and pending work.
It never substitutes an older successful run. A successful dispatch means the
requests were accepted; it does not mean the benchmarks passed. A failed or
partial dispatch retains its receipt for inspection before another dispatch.

`BOT_PUBLIC_GITHUB_TOKEN` must have Actions write access to the registered
benchmark repositories and Actions read access to this repository. The workflow
also supports a manual dispatch with an exact canary tag. Preview without
starting builds with `ruby scripts/nightly-canaries.rb --dry-run`.

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
