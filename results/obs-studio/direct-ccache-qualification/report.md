# obs-studio: direct-ccache-qualification

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Cache restore/setup plus the upstream Building obs-studio log group; dependency installation, CMake configuration, queueing, and post-job cache save are excluded

Observations: 0/4 recorded; 0 failed; 4 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |

Run 37063464018 failed completion checks:

- Workflow concluded failure
- BoringCache OBS ccache cold: failure

Run 37063467317 failed completion checks:

- Workflow concluded failure
- GitHub Actions OBS ccache cold: failure

Missing observations:

- Sample 1, BoringCache, Cold build
- Sample 1, Actions Cache, Cold build
- Sample 1, BoringCache, Changed-source build
- Sample 1, Actions Cache, Changed-source build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |

[Full records and checks](report.json)
