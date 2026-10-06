# storybook: baseline-20261006-rolling-7

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed Storybook sandbox build plus measured cache restore/setup; dependency installation and sandbox creation are excluded; output checks and unmeasured cache publication are reported separately

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 15 | 15–15 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | 21 | 21–21 | unmeasured | 0 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

Missing completion checks: 37429906464


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 0 | 15 | 15 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Changed-source build | 5 | 16 | 21 | unmeasured | unmeasured | miss | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
