# posthog: image-output-qualification-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed Docker build including image export and load, plus measured provider setup; output inspection is outside the timed build; provider post-job work is reported separately

Status: 2 declared observations missing; 0 failed. Publication requires review.

Execution: unqualified; missing or failed job completion checks. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Median build_and_reuse_seconds | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| cold | actions-cache | 1 | 1579 | 1579–1579 | unmeasured | 0 |
| cold | boringcache | 1 | 813 | 813–813 | 6237669195 | 1 |

Methodology prevents a comparative claim:

- Both warm jobs failed before building because legacy published-scope validation ran before native series scope resolution.
- Cold build_seconds includes the superseded loaded-image inspection, contrary to the declared timing scope. Preserve as diagnostic; corrected execution uses a new series.
- The execution definition exported Actions Cache state on warm replay while BoringCache used restore-only trust. These observations do not compare the same publication lifecycle.
- The workflow retained derived phase records but did not retain the original final BoringCache Action evidence JSON after cleanup.

Run 37104600856 failed completion checks:

- Workflow concluded failure
- GitHub Actions posthog warm: failure
- BoringCache posthog warm: failure

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
