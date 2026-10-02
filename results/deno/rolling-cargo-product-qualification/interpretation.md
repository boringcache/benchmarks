# Deno Cargo-product rolling qualification

The declared run [37063477982](https://github.com/boringcache/benchmarks/actions/runs/37063477982)
failed while uploading its rolling report. The two Cargo operations, output
verification, phase writing, and summarization steps passed. The uploader expected
`deno-cargo-boringcache-rolling.json`; the reporter wrote
`deno-cargo-boringcache-cargo-product-rolling.json`.

The subsequent artifact step was skipped, so the original phase JSON and product
evidence files were not retained. No timing records were reconstructed from log
lines. The series remains incomplete with a failed completion and supports no
performance or storage claim.

The case now retains the profile-specific summary under its actual filename and
uploads raw phase and product evidence even when a later step fails. The report
contract checks the selected cache profile's output name.

This run published into the declared cache cohort before its report upload
failed. Repeating the old dispatch cannot be treated as another changed-source
observation. A replacement must declare its actual seed and destination source,
use a fresh seed or prove the retained cohort's source lineage, and preserve its
own evidence before qualification.
