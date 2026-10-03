# hugo: image-output-qualification-01

The [original run](https://github.com/boringcache/benchmarks/actions/runs/37104595025) executed its frozen request at `35e10981f5e27824d81b19c575a91691592905e9`.

Both cold builds failed because the Docker exporter cannot export the requested attestation manifest list. No original verified phase JSON exists, so no measurements were reconstructed. Corrected loaded-image execution disables provenance and SBOM attestations in both providers and uses a new plan.

The [generated report](report.md) retains 0 original phase records. Completion is `failed`; comparative use is `false`. Sample count is one; publication remains unreviewed.

Provider-reported storage stays labelled by its source. Missing measurements remain unmeasured; no cross-provider total storage saving is established. Repository-wide cache snapshots do not prove per-phase occupancy or absence of eviction.

Evidence preservation is scoped to this run. It does not qualify every variant, caller cutover, website publication, or repository deletion.
