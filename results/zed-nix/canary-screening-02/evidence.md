# Retained failed Nix screen

[Run 37296214039](https://github.com/boringcache/benchmarks/actions/runs/37296214039)
failed both warm jobs at the dependency-baseline comparison. Both providers
restored the measured Zed package, verified its output and produced matching
package closure records. The separately built dependency closure differed
between workers. This run does not qualify the cold/warm comparison.

The [original evidence bundle](https://github.com/boringcache/benchmarks/releases/download/evidence-cadence-2026-10-05/benchmarks-37296214039.tar.gz)
includes the available run, attempts, jobs, logs, artifacts, commit and workflow.
The published archive was downloaded again, its SHA-256 matched, and all 15
listed files and its scoped inventory passed verification without gaps.
See [the archive inventory](../../../migration/evidence.json).
