# obs-studio: cadence-rolling-seed-ccache

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Observations: 1/2 recorded; 0 failed; 1 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 577.6759015939999 | 577.6759015939999–577.6759015939999 | unmeasured | 0 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.

Run 37322616359 failed completion checks:

- Workflow concluded failure
- BoringCache obs-studio ccache commit: failure
- obs-studio rolling report: failure

Missing observations:

- Sample 1, BoringCache, Changed-source build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 0 | 577.6759015939999 | 577.6759015939999 | unmeasured | unmeasured | miss | [JSON](runs/1-actions-cache-commit.json) |

[Full records and checks](report.json)
