# n8n: baseline-20261006-rolling-15

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Selected workload build plus measured provider setup: Turbo excludes dependency installation; Docker includes image export and load and excludes prepared source setup. Output checks and unmeasured post-job work are reported separately

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 101 | 101–101 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | 129 | 129–129 | 46409269 | 1 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

Missing completion checks: 37429928768


## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 0 | 101 | 101 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Changed-source build | 2 | 127 | 129 | 46409269 | boringcache-check | miss | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
