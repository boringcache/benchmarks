# BoringCache benchmarks

**Real repositories. Exact runs.**

This repository is the public index and contract suite behind BoringCache
benchmarks. The [product benchmark page](https://boringcache.com/benchmarks)
shows the best results we measured; every number links back to its public run.

## What lives here

- [`data/latest/report.md`](data/latest/report.md) — the latest published cohort report
- [`data/latest/index.json`](data/latest/index.json) — machine-readable workload index
- [`data/latest/providers.json`](data/latest/providers.json) — provider comparison data
- [`scripts/`](scripts) — report, evidence, registry, and workflow checks
- [`test/`](test) — contracts that keep public evidence internally consistent

Individual workload repositories under the
[`boringcache` organization](https://github.com/orgs/boringcache/repositories?q=benchmark-)
hold the workflows, pinned source revisions, logs, and run history.

## Read the result

A timing comparison names the workload and comparator. Storage results stay
storage results. Native cache reuse stays tool-reported hits and misses. The
same public run remains attached to the claim so the result can be inspected
without trusting a copied screenshot.

[See the benchmark scoreboard →](https://boringcache.com/benchmarks)
