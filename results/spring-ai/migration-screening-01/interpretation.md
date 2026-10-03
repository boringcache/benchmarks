# Spring AI fresh screening

[Run 37085344978](https://github.com/boringcache/benchmarks/actions/runs/37085344978)
completed the predeclared cold and identical-source replay for both providers from
signed harness `da6400b319991a6b5e36b1e2fc70eaca2619a560`, using CLI 1.33.0.
The checked Maven artifact, matched source and runner environment, job completion,
and post-step checks passed. Original observations remain in the
[generated report](report.json).

Build plus measured cache setup was 519 seconds for BoringCache and 514 for
Actions Cache cold, then 83 and 118 seconds respectively for replay. The slower
BoringCache cold observation remains included. Maven's build command includes
its own dependency resolution. Queue and complete job duration are context.
Actions Cache cold storage is unmeasured. The byte counts describe selected
provider caches and do not establish physical storage efficiency.

There is one sample per phase and provider. The [durable evidence](evidence.md)
was independently downloaded and verified. Publication remains unreviewed;
changed-source reuse, rolling publication, and caller cutover remain unqualified.
