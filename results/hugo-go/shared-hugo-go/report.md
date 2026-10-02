# hugo-go: shared-hugo-go

Question: How do build and cache reuse time and measured storage compare for the same pinned workload?

Measured scope: Timed build entrypoint plus measured cache restore/setup; upstream dependency installation remains included when the entrypoint performs it; unmeasured post-job save is reported separately

Status: all declared observations collected; 0 failed. Publication requires review.

Execution: unqualified; missing or failed job completion checks. Timings alone do not qualify the series.

Queue time, dependency setup outside the declared scope, and job duration are context. They are excluded from the comparison. No observations were excluded.

| Phase | Provider | Successful observations | Median build_and_reuse_seconds | Range | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| cold | actions-cache | 2 | 71.0 | 63–79 | unmeasured | 0 |
| warm | actions-cache | 2 | 9.5 | 9–10 | 161823175.0 | 2 |
| cold | boringcache | 2 | 93.0 | 91–95 | 732124253.5 | 2 |
| warm | boringcache | 2 | 27.0 | 20–34 | 732124253.5 | 2 |

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

Each run record retains its source, runner environment, verification, provider storage source, and evidence links. Missing storage is unmeasured; it is not zero. Original Actions URLs remain subject to retention; durable evidence publication must be verified before publication review.
