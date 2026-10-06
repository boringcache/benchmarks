# storybook: cadence-37429783479-7

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed Storybook sandbox build plus measured cache restore/setup; dependency installation and sandbox creation are excluded; output checks and unmeasured cache publication are reported separately

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 1 | 15 | 15–15 | unmeasured | 0 |
| Warm build | Actions Cache | 1 | 16 | 16–16 | 4490824 | 1 |
| Cold build | BoringCache | 1 | 18 | 18–18 | unmeasured | 0 |
| Warm build | BoringCache | 1 | 21 | 21–21 | 4287929 | 1 |

Missing completion checks: 37429887478


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 15 | 15 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 0 | 16 | 16 | 4490824 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 2 | 16 | 18 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 6 | 15 | 21 | 4287929 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
