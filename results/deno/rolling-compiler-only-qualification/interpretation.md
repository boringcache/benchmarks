# Deno compiler-only rolling qualification

[Run 37063481150](https://github.com/boringcache/benchmarks/actions/runs/37063481150)
failed uploading the profile-specific rolling summary. Its builds, output
verification, phase writing, and summarization passed. The uploader expected
`deno-cargo-boringcache-rolling.json`; the reporter wrote
`deno-cargo-boringcache-compiler-only-rolling.json`.

The subsequent evidence uploader was skipped. The original structured phase and
product files were never uploaded and are unavailable. No records were
reconstructed from log lines. The failed completion and incomplete report cannot
support performance or storage claims.
The [verified archive](evidence.md) preserves the available metadata and logs,
with the missing phase and product files recorded explicitly.

This dispatch used signed harness `50f069f123cef134e307db653c853d39eee08404`,
before the fix merged. Main now uploads the selected profile's summary filename
and preserves raw phase and product evidence after a later reporting failure.

This run published into the declared cohort before report upload failed. A
replacement must establish the actual seed and next source revision, or use a
fresh seed. Repeating the old head in that cohort cannot qualify as another
changed-source observation.
