# n8n Turbo fresh screening

[Run 37087350856](https://github.com/boringcache/benchmarks/actions/runs/37087350856)
completed the predeclared cold and identical-source replay for both providers from
signed harness `6eda03c19ffe66ff3d0d6b3d9f76fb2a2860ac0c`, using CLI 1.33.0.
The built CLI entrypoint, matched source and runner environment, job completion,
and post-step checks passed. Original observations remain in the
[generated report](report.json).

Build plus measured cache setup was 132 seconds for BoringCache and 125 for
Actions Cache cold, then 9 and 4 seconds respectively for replay. Both slower
BoringCache observations remain included. Dependency installation runs outside
the setup and build timers. The output check establishes the built entrypoint;
it does not test application runtime behavior. Queue and job duration are context.

Actions Cache cold storage is unmeasured. Selected provider byte counts do not
establish physical storage efficiency. There is one sample per phase and provider.
The [durable evidence](evidence.md) was independently downloaded and verified.
Publication remains unreviewed. Docker variants, changed-source reuse, rolling
publication, and caller cutover require separate qualification.
