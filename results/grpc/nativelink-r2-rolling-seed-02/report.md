# grpc: nativelink-r2-rolling-seed-02

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Bazel build with local top-level outputs plus measured cache restore/setup; output checks and post-job cache save are outside build timing

Observations: 4/4 recorded; 0 failed; 0 missing.

Completion checks: passed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Changed-source build | Actions Cache | 1 | 2515 | 2515–2515 | 163681814 | 1 |
| Changed-source build | BoringCache | 1 | 2231 | 2231–2231 | 611186376 | 1 |
| Changed-source build | BuildBuddy | 1 | 1602 | 1602–1602 | unmeasured | 0 |
| Changed-source build | NativeLink (R2) | 1 | 3381 | 3381–3381 | 707856686 | 1 |

Comparison checks:

- This is a bootstrap seed, not changed-source reuse. NativeLink installation was excluded from setup timing while BoringCache installation was included. Retain it as cache and output evidence, not a provider timing comparison.
- Rolling seed and changed-source sequence are unverified.

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Changed-source build | 0 | 2515 | 2515 | 163681814 | github-actions-cache-api | not reported | [JSON](runs/1-actions-cache-commit.json) |
| 1 | BoringCache | Changed-source build | 2 | 2229 | 2231 | 611186376 | boringcache-check | not reported | [JSON](runs/1-boringcache-commit.json) |
| 1 | BuildBuddy | Changed-source build | 0 | 1602 | 1602 | unmeasured | unmeasured | not reported | [JSON](runs/1-buildbuddy-commit.json) |
| 1 | NativeLink (R2) | Changed-source build | 5 | 3376 | 3381 | 707856686 | cloudflare-r2-list-objects-v2 | miss | [JSON](runs/1-nativelink-commit.json) |

[Full records and checks](report.json)
