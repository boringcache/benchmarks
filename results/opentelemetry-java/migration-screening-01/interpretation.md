# OpenTelemetry Java fresh screening

[Run 37085341225](https://github.com/boringcache/benchmarks/actions/runs/37085341225)
completed the predeclared one-sample comparison from signed harness
`da6400b319991a6b5e36b1e2fc70eaca2619a560`, using CLI 1.33.0.
Both providers passed the declared recipe, output, job-completion, and post-step
checks. The [generated report](report.json) retains all four observations.

| Phase | BoringCache build and reuse | Actions Cache build and reuse |
| --- | ---: | ---: |
| Cold | 975 s | 966 s |
| Identical-source replay | 150 s | 171 s |

These measurements cover the declared build entrypoint and measured provider
setup. They do not isolate compiler time or establish a repeated performance
advantage. The slower BoringCache cold result remains in the series.

BoringCache reported 51,294,699 bytes in both phases. Actions Cache reported
50,739,407 bytes for replay; its cold storage was unmeasured. These are selected
provider cache sizes, not billable or physical storage-efficiency measurements.

The [durable evidence](evidence.md) was independently downloaded and verified.
Publication remains unreviewed. Rolling source changes, source advancement,
schedules, and canary/release caller cutover require separate qualification.
