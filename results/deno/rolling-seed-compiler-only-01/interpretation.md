# Deno compiler-only rolling seed

[Run 37085349929](https://github.com/boringcache/benchmarks/actions/runs/37085349929)
completed the predeclared one-sample cold/adjacent-source correctness proof from
signed harness `da6400b319991a6b5e36b1e2fc70eaca2619a560`, using CLI 1.33.0.
Both phases passed binary-output, job-completion, and post-step checks. The
[generated report](report.json) retains both original phase records.

The cold parent published the `r37085349929-a1` compiler-only cohort. The
adjacent-source consumer restored it with `write_allowed: false`; it did not
advance that seed. Raw native-tool evidence reports cold primary cache errors 10;
changed primary cache errors 10 and cache-write errors 52; changed desktop
cache-write errors 3. Successful outputs do not establish an error-free native
cache operation or identify the errors' cause.

The selected compiler-cache probe measured 1,998,300,801 bytes in both phases.
It does not describe total workspace storage. This series declares correctness
and has one provider; it does not support a timing or storage comparison.

The [durable evidence](evidence.md) was independently downloaded and verified.
Publication remains unreviewed. A rolling publication run, its declared source
sequence and seed lineage, and the full release caller still need qualification.
