# gRPC cold/warm repair qualification

One sample tests the corrected Ruby verifier, shared case/series scope, and
client/server output checks with GitHub Actions Cache, BuildBuddy, and BoringCache.
Use CLI `vcli-canary-4c236cd7ee00` through the existing pinned Action. BuildBuddy
uses the repository secret; the retired organization credential is removed.

All three providers must complete cold and warm builds and produce both declared
executables. Inspect cache hits, native errors, post-step completion, storage,
and retained evidence. Executable checks establish materialized outputs, not
client/server integration behavior. Keep unmeasured storage explicit.

The original interpreter failure remains preserved. This new definition is a
separate screening series and does not establish a release performance result.
