# Deno CLI canary repeat

This is one additional fresh cold/changed-source observation of CLI
`vcli-canary-4c236cd7ee00`, requested after run
[37231027672](https://github.com/boringcache/benchmarks/actions/runs/37231027672).
Execution uses the same harness definition from `3ebdc9c8`, source pair, Cargo
product profile, BoringCache Action pin, and `ubuntu-24.04` runner class. The
runner image actually assigned must be checked in the resulting evidence.

The base publishes a new run-scoped seed. The changed-source consumer restores
without advancing that seed. This repeats the fresh bootstrap observation; it
does not establish reuse from a verified rolling seed or compare another cache
provider. Standard-library freshness safety remains enabled.

Retain output verification, measured build/reuse time, native compiler statistics,
errors, final product evidence, and completed job/post-step logs. The original
harness includes the obsolete `check --exact` storage probe, so absent storage
must remain unmeasured. The corrected reporter on `main` is unchanged by this
historical execution branch.

The plan declares one additional observation. Preserve its outcome regardless of
timing; it does not by itself approve regression acceptance or publication.
