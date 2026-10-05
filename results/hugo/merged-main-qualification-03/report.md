# hugo: merged-main-qualification-03

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed Docker build including image export and load, plus measured provider setup; output inspection is outside the timed build; provider post-job work is reported separately

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 211 | 211–211 | unmeasured | 0 |
| Warm build | Actions Cache | 1 | 22 | 22–22 | unmeasured | 0 |
| Cold build | BoringCache | 1 | 222 | 222–222 | 411516403 | 1 |
| Warm build | BoringCache | 1 | 25 | 25–25 | 411516403 | 1 |

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 9 | 202 | 211 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 6 | 16 | 22 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 0 | 222 | 222 | 411516403 | boringcache-check | reuse not measured (1 refs planned) | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0 | 25 | 25 | 411516403 | boringcache-check | reuse not measured (1 refs planned) | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
