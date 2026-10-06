# qdrant: baseline-20261006-rolling-14

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 779 | 779–779 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | 580 | 580–580 | 2081582205 | 1 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

Missing completion checks: 37429926318


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 5 | 774 | 779 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Changed-source build | 0 | 580 | 580 | 2081582205 | boringcache-check | reuse not measured (1 refs planned) | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
