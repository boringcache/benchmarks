# Storybook fresh screening limitation

[Run 37085346780](https://github.com/boringcache/benchmarks/actions/runs/37085346780)
completed the predeclared cold and identical-source replay for both providers from
signed harness `da6400b319991a6b5e36b1e2fc70eaca2619a560`, using CLI 1.33.0.
The Storybook static output, matched source and runner environment, job completion,
and post-step checks passed. Original observations remain in the
[generated report](report.json).

Review found that the setup timer also included dependency installation and
creation of the upstream sandbox. Its reported build-and-reuse metric therefore
does not isolate cache setup and build. Retain this series as diagnostic; do not
use it for the intended build-and-reuse comparison. Do not subtract estimated
setup durations or replace the original measurements. The primary totals were
307 seconds for BoringCache and 245 for Actions Cache cold, then 268 and 270 for
replay. These combined totals are not standalone compile or cache performance.

Cold storage is unmeasured for both providers. Replay byte counts describe the
selected provider caches. There is one sample per phase and provider.
The [durable evidence](evidence.md) was independently downloaded and verified.
Publication remains unreviewed. The corrected timer boundary needs a new frozen
series before execution. Rolling publication and caller cutover remain unqualified.
