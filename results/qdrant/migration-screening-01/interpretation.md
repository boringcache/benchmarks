# Qdrant fresh screening

[Run 37085343088](https://github.com/boringcache/benchmarks/actions/runs/37085343088)
completed the predeclared one-sample comparison from signed harness
`da6400b319991a6b5e36b1e2fc70eaca2619a560`, using CLI 1.33.0.
Both providers loaded the declared image and passed output, job-completion,
and post-step checks. The [generated report](report.json) retains all four
observations.

| Phase | BoringCache build and reuse | Actions Cache build and reuse |
| --- | ---: | ---: |
| Cold | 576 s | 804 s |
| Identical-source replay | 25 s | 21 s |

The measurement includes the declared Docker build, image load, and measured
provider setup. One sample does not establish a repeated performance advantage.
The slower BoringCache replay remains in the series.

BoringCache reported 2,084,676,721 bytes in both phases. Actions Cache storage was
unmeasured in both phases. No relative storage-efficiency claim is supported.

The [durable evidence](evidence.md) was independently downloaded and verified.
Publication remains unreviewed. Image inspection does not test application
runtime behavior. Rolling source changes, source advancement, schedules, and
canary/release caller cutover require separate qualification.
