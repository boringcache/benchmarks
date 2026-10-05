# posthog: image-output-qualification-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed Docker build including image export and load, plus measured provider setup; output inspection is outside the timed build; provider post-job work is reported separately

Observations: 2/4 recorded; 0 failed; 2 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 1579 | 1579–1579 | unmeasured | 0 |
| Cold build | BoringCache | 1 | 813 | 813–813 | 6237669195 | 1 |

Comparison checks:

- Both warm jobs failed before building because legacy published-scope validation ran before native series scope resolution.
- Cold build_seconds includes the superseded loaded-image inspection, contrary to the declared timing scope. Preserve as diagnostic; corrected execution uses a new series.
- The execution definition exported Actions Cache state on warm replay while BoringCache used restore-only trust. These observations do not compare the same publication lifecycle.
- The workflow retained derived phase records but did not retain the original final BoringCache Action evidence JSON after cleanup.

Run 37104600856 failed completion checks:

- Workflow concluded failure
- GitHub Actions posthog warm: failure
- BoringCache posthog warm: failure

Missing observations:

- Sample 1, BoringCache, Warm build
- Sample 1, Actions Cache, Warm build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 7 | 1572 | 1579 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | BoringCache | Cold build | 0 | 813 | 813 | 6237669195 | boringcache-check | reuse not measured (2 refs planned) | [JSON](runs/1-boringcache-cold.json) |

[Full records and checks](report.json)
