# mastodon: image-output-qualification-01

The [original run](https://github.com/boringcache/benchmarks/actions/runs/37104599574) executed its frozen request at `35e10981f5e27824d81b19c575a91691592905e9`.

Both providers completed the declared cold and identical-source replay, including export and load. Logs and original phase records establish that the shared verifier inspected the selected local image after timing capture. This establishes image materialization, not runtime application correctness. Slower observations remain in the report.

The [generated report](report.md) retains 4 original phase records. Completion is `success`; comparative use is `true`. Sample count is one; publication remains unreviewed.

Provider-reported storage stays labelled by its source. Missing measurements remain unmeasured; no cross-provider total storage saving is established. Repository-wide cache snapshots do not prove per-phase occupancy or absence of eviction.

Evidence preservation is scoped to this run. It does not qualify every variant, caller cutover, website publication, or repository deletion.
