# n8n: cadence-37429783479-20

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Selected workload build plus measured provider setup: Turbo excludes dependency installation; Docker includes image export and load and excludes prepared source setup. Output checks and unmeasured post-job work are reported separately

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 168 | 168–168 | unmeasured | 0 |
| Warm build | Actions Cache | 1 | 109 | 109–109 | unmeasured | 0 |
| Cold build | BoringCache | 1 | 78 | 78–78 | 578003328 | 1 |
| Warm build | BoringCache | 1 | 120 | 120–120 | 578003328 | 1 |

Missing completion checks: 37429886645


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 12 | 156 | 168 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 7 | 102 | 109 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 0 | 78 | 78 | 578003328 | boringcache-check | reuse not measured (2 refs planned) | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0 | 120 | 120 | 578003328 | boringcache-check | reuse not measured (2 refs planned) | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
