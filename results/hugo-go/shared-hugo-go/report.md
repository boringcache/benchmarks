# hugo-go: shared-hugo-go

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Observations: 8/8 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Median build and cache reuse (s) | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| Cold build | Actions Cache | 2 | 71.0 | 63–79 | unmeasured | 0 |
| Warm build | Actions Cache | 2 | 9.5 | 9–10 | 161823175.0 | 2 |
| Cold build | BoringCache | 2 | 93.0 | 91–95 | 732124253.5 | 2 |
| Warm build | BoringCache | 2 | 27.0 | 20–34 | 732124253.5 | 2 |

Run 37017469085 failed completion checks:

- 2026-10-02T14:08:59.5369049Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss
- 2026-10-02T14:08:59.5369023Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss
- 2026-10-02T14:07:51.0368756Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss
- 2026-10-02T14:07:51.0368713Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss

Run 37017742296 failed completion checks:

- 2026-10-02T14:12:29.9176397Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss
- 2026-10-02T14:12:29.9176349Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss
- 2026-10-02T14:11:31.8617554Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss
- 2026-10-02T14:11:31.8617514Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | Actions Cache | Cold build | 0 | 79 | 79 | unmeasured | unmeasured | not reported | [JSON](runs/1-actions-cache-cold.json) |
| 1 | Actions Cache | Warm build | 3 | 7 | 10 | 161835626 | github-actions-cache-api | hit | [JSON](runs/1-actions-cache-warm.json) |
| 1 | BoringCache | Cold build | 3 | 92 | 95 | 652745399 | boringcache-check | miss | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 10 | 24 | 34 | 652745399 | boringcache-check | hit | [JSON](runs/1-boringcache-warm.json) |
| 2 | Actions Cache | Cold build | 0 | 63 | 63 | unmeasured | unmeasured | not reported | [JSON](runs/2-actions-cache-cold.json) |
| 2 | Actions Cache | Warm build | 2 | 7 | 9 | 161810724 | github-actions-cache-api | hit | [JSON](runs/2-actions-cache-warm.json) |
| 2 | BoringCache | Cold build | 6 | 85 | 91 | 811503108 | boringcache-check | miss | [JSON](runs/2-boringcache-cold.json) |
| 2 | BoringCache | Warm build | 11 | 9 | 20 | 811503108 | boringcache-check | hit | [JSON](runs/2-boringcache-warm.json) |

[Full records and checks](report.json)
