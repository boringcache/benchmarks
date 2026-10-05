# Cadence qualification — October 5, 2026

All seventeen rolling targets have passed a seed run and an actual source
advancement with both providers. Zed Nix also passed both fresh samples. This is
an operational correctness review; these single-sample pairs do not establish
comparative performance. All runs use `vcli-canary-7a5b27146ebe`.

The [machine-readable inventory](../migration/cadence-qualification-2026-10-05.json)
records frozen plans, exact sources, cache scopes and selected run IDs. Earlier
failed and cancelled cohorts remain in `results/`; corrected cohorts have new
plans. The [evidence inventory](../migration/evidence.json) links archives that
were downloaded again and verified after publication.

Large archives use a JSON index as `bundle_url`. Its `sha256` and `bundle_bytes`
describe that index; `archive_sha256` and `archive_bytes` describe the reconstructed
tar.gz file. Download and verify each listed part, concatenate the parts in order,
verify the resulting archive, then extract it. The hosted preservation workflow
performs those checks and verifies every exported file before recording success.

| Case / variant | Seed | Changed source | Result |
| --- | --- | --- | --- |
| immich | [37321739971](https://github.com/boringcache/benchmarks/actions/runs/37321739971) | [37323121773](https://github.com/boringcache/benchmarks/actions/runs/37323121773) | Passed |
| mastodon / server | [37321744434](https://github.com/boringcache/benchmarks/actions/runs/37321744434) | [37323126507](https://github.com/boringcache/benchmarks/actions/runs/37323126507) | Passed |
| mastodon / streaming | [37321748690](https://github.com/boringcache/benchmarks/actions/runs/37321748690) | [37323131290](https://github.com/boringcache/benchmarks/actions/runs/37323131290) | Passed |
| n8n / distroless | [37321753318](https://github.com/boringcache/benchmarks/actions/runs/37321753318) | [37323140444](https://github.com/boringcache/benchmarks/actions/runs/37323140444) | Passed |
| n8n / docker | [37321758035](https://github.com/boringcache/benchmarks/actions/runs/37321758035) | [37323145174](https://github.com/boringcache/benchmarks/actions/runs/37323145174) | Passed |
| n8n / runners | [37321762921](https://github.com/boringcache/benchmarks/actions/runs/37321762921) | [37323150431](https://github.com/boringcache/benchmarks/actions/runs/37323150431) | Passed |
| n8n / turbo | [37321767409](https://github.com/boringcache/benchmarks/actions/runs/37321767409) | [37323155106](https://github.com/boringcache/benchmarks/actions/runs/37323155106) | Passed |
| posthog / layers | [37321772493](https://github.com/boringcache/benchmarks/actions/runs/37321772493) | [37323164071](https://github.com/boringcache/benchmarks/actions/runs/37323164071) | Passed |
| executorch-buck2 | [37324032100](https://github.com/boringcache/benchmarks/actions/runs/37324032100) | [37324204556](https://github.com/boringcache/benchmarks/actions/runs/37324204556) | Passed |
| gogs-moon | [37325135541](https://github.com/boringcache/benchmarks/actions/runs/37325135541) | [37325282767](https://github.com/boringcache/benchmarks/actions/runs/37325282767) | Passed |
| opencut-moon | [37325140807](https://github.com/boringcache/benchmarks/actions/runs/37325140807) | [37325287254](https://github.com/boringcache/benchmarks/actions/runs/37325287254) | Passed |
| stackstorm-pants | [37324025714](https://github.com/boringcache/benchmarks/actions/runs/37324025714) | [37324228460](https://github.com/boringcache/benchmarks/actions/runs/37324228460) | Passed |
| msgpack-sbt | [37324036688](https://github.com/boringcache/benchmarks/actions/runs/37324036688) | [37324214890](https://github.com/boringcache/benchmarks/actions/runs/37324214890) | Passed |
| obs-studio / ccache | [37323465858](https://github.com/boringcache/benchmarks/actions/runs/37323465858) | [37324219008](https://github.com/boringcache/benchmarks/actions/runs/37324219008) | Passed |
| obs-studio / xcode | [37326133177](https://github.com/boringcache/benchmarks/actions/runs/37326133177) | [37326340221](https://github.com/boringcache/benchmarks/actions/runs/37326340221) | Passed |
| helix-nix | [37322604229](https://github.com/boringcache/benchmarks/actions/runs/37322604229) | [37323117664](https://github.com/boringcache/benchmarks/actions/runs/37323117664) | Passed |
| zed-nix | [37322636399](https://github.com/boringcache/benchmarks/actions/runs/37322636399) | [37323174641](https://github.com/boringcache/benchmarks/actions/runs/37323174641) | Passed |

The five REAPI comparator archives identify the intended previous run and source
in `rolling-seed.json`. Both OBS comparator archives likewise identify their
intended seed in `previous-cache-source.json`. The review checks those identities
against the frozen plans; a cache flag alone is insufficient.

The first n8n Turbo advancement retained an available BoringCache entry but
reported zero native hits. A further actual upstream revision in
[run 37325183094](https://github.com/boringcache/benchmarks/actions/runs/37325183094)
reported 70 native hits and 2 misses. Both observations remain retained. Changed
source does not guarantee a hit; absence of a hit must not be reported as reuse.

Helix Nix passed two fresh cold/warm samples and its rolling pair. Zed Nix passed both fresh cold/warm samples and its rolling pair. Each Nix run imports one checksummed
dependency store into its provider workers and checks the dependency baseline.
The measured package is excluded from that seed. A changed package derivation
may require a build even when the rolling provider cache is available.

The shared controller passed a 24-case hosted planning rehearsal, and fresh
dispatch passed the complete 31-target dry run. The
[publication rehearsal](../migration/rehearsals/mastodon-publication/review.md)
passed isolated conditional publication, dispatch, reconciliation and a forced
concurrent-write conflict. It used the operator token; the first activated cycle
must verify workflow-token writes on `main`.

Central activation remains off by request until a compatible stable CLI release.
The [cutover procedure](cadence-cutover.md) preserves manual entrypoints and
drains historical runs before central ownership begins. The prepared historical
schedule patches have not been applied.
