# obs-studio: cadence-rolling-seed-ccache-02

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 644.054199763 | 644.054199763–644.054199763 | unmeasured | 0 |
| Changed-source build | BoringCache | 1 | 631.7126567849999 | 631.7126567849999–631.7126567849999 | 172201371 | 1 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 1 | 643.054199763 | 644.054199763 | unmeasured | unmeasured | miss | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Changed-source build | 2 | 629.7126567849999 | 631.7126567849999 | 172201371 | boringcache-check | miss | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
