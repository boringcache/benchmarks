# NativeLink rolling qualification

This isolated branch seeds all four gRPC providers at parent commit
`08455f8f03d2b1508ae233d950704ec06cb19017`, then advances to
`e1245717f658d10fee8fa0ea7b6f301a872330f2`. The latter changes the compiled
gRPC core version and associated build metadata. The reviewed CSM target
contract is identical at both commits.

Both observations use `BENCHMARK_ROLLING_SCOPE=nativelink-r2-20261005-v2`.
This explicit rehearsal scope preserves provider caches across two source-specific
frozen series. It is not a production scope change. Do not merge the isolated
source pin or workflow override. Preserve both successful and failed attempts.

Require the NativeLink advancement evidence to identify the seed source/run,
report remote hits, and verify both executable outputs. The seed alone does not
qualify rolling reuse. Two fresh samples run separately with isolated prefixes.

The initial 45-minute seed attempt was cancelled after identifying an insufficient
bootstrap budget: a prior successful Actions Cache cold build took 54 minutes.
The replacement uses 90 minutes and a new scope; it does not reuse partial objects.

The unexecuted advancement plan `nativelink-r2-rolling-advance-02` is superseded
by `nativelink-r2-rolling-advance-03`. The latter tests installation inside setup
timing, bounded seed lookup, and separate raw R2 inventory retention. NativeLink
version, cache configuration, build commands, and the shared R2 prefix are unchanged.
The seed used the earlier setup boundary; these seed/advance observations qualify
cache continuity and outputs, not a timing comparison between those definitions.
