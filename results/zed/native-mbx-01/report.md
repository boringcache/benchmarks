# zed: native-mbx-01

Question: Does the pinned workload produce verified output and reuse its declared cache?

Measured scope: The BoringCache Cargo operations, including their restore, build, and publication; output verification and unrelated setup are excluded. The layer proof uses a combined cold seed for each restore-only variant and makes no provider timing comparison.

Observations: 0/2 recorded; 0 failed; 2 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |

Comparison checks:

- This series does not declare a comparison of provider performance.

Run 37376777074 failed completion checks:

- Workflow concluded failure
- Cold: target + mbx seed: failure

Missing observations:

- Sample 1, BoringCache, Cold build
- Sample 1, BoringCache, Changed-source build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |

[Full records and checks](report.json)
