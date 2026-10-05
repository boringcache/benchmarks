# mastodon: cadence-rolling-seed-streaming

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed Docker build including image export and load, plus measured provider setup; output inspection is outside the timed build; provider post-job work is reported separately

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 32 | 32–32 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | 27 | 27–27 | 106284886 | 1 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 8 | 24 | 32 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Changed-source build | 0 | 27 | 27 | 106284886 | boringcache-check | reuse not measured (2 refs planned) | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
