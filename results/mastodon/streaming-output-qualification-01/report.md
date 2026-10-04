# mastodon: streaming-output-qualification-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed Docker build including image export and load, plus measured provider setup; output inspection is outside the timed build; provider post-job work is reported separately

Status: all declared observations collected; 0 failed. Publication requires review.

Execution: preserved job completion and post-step logs verified. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Median build_and_reuse_seconds | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| cold | actions-cache | 1 | 52 | 52–52 | unmeasured | 0 |
| warm | actions-cache | 1 | 21 | 21–21 | unmeasured | 0 |
| cold | boringcache | 1 | 40 | 40–40 | 106281953 | 1 |
| warm | boringcache | 1 | 22 | 22–22 | 106281953 | 1 |

Methodology prevents a comparative claim:

- The execution definition exported Actions Cache state on warm replay while BoringCache used restore-only trust. These observations do not compare the same publication lifecycle.
- The workflow retained derived phase records but did not retain the original final BoringCache Action evidence JSON after cleanup.

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
