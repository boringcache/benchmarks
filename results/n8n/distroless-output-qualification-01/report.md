# n8n: distroless-output-qualification-01

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Selected workload build plus measured provider setup: Turbo excludes dependency installation; Docker includes image export and load and excludes prepared source setup. Output checks and unmeasured post-job work are reported separately

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 214 | 214–214 | unmeasured | 0 |
| Warm build | Actions Cache | 1 | 132 | 132–132 | unmeasured | 0 |
| Cold build | BoringCache | 1 | 81 | 81–81 | 581055738 | 1 |
| Warm build | BoringCache | 1 | 110 | 110–110 | 581055738 | 1 |

Comparison checks:

- The execution definition exported Actions Cache state on warm replay while BoringCache used restore-only trust. These observations do not compare the same publication lifecycle.
- The workflow retained derived phase records but did not retain the original final BoringCache Action evidence JSON after cleanup.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 9 | 205 | 214 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 8 | 124 | 132 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 0 | 81 | 81 | 581055738 | boringcache-check | reuse not measured (2 refs planned) | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0 | 110 | 110 | 581055738 | boringcache-check | reuse not measured (2 refs planned) | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
