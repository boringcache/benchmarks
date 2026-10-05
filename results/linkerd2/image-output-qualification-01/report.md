# linkerd2: image-output-qualification-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed Docker build including image export and load, plus measured provider setup; output inspection is outside the timed build; provider post-job work is reported separately

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 306 | 306–306 | unmeasured | 0 |
| Warm build | Actions Cache | 1 | 15 | 15–15 | unmeasured | 0 |
| Cold build | BoringCache | 1 | 200 | 200–200 | 1230761384 | 1 |
| Warm build | BoringCache | 1 | 12 | 12–12 | 1230761384 | 1 |

Comparison checks:

- The execution definition exported Actions Cache state on warm replay while BoringCache used restore-only trust. These observations do not compare the same publication lifecycle.
- The workflow retained derived phase records but did not retain the original final BoringCache Action evidence JSON after cleanup.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 8 | 298 | 306 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 10 | 5 | 15 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 0 | 200 | 200 | 1230761384 | boringcache-check | reuse not measured (1 refs planned) | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0 | 12 | 12 | 1230761384 | boringcache-check | reuse not measured (1 refs planned) | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
