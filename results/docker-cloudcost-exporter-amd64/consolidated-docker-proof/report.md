# docker-cloudcost-exporter-amd64: consolidated-docker-proof

Question: Does the pinned workload produce verified output and reuse its declared cache?

Measured scope: Declared Docker build, including dependencies, cache import/export and declared image output

Observations: 2/2 recorded; 0 failed; 0 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Cold build | BoringCache | 1 | unmeasured | 0 |
| Warm build | BoringCache | 1 | unmeasured | 0 |

Comparison checks:

- This series does not declare a comparison of provider performance.

Run 37018647268 failed completion checks:

- 2026-10-02T14:22:14.0284432Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss
- 2026-10-02T14:22:14.0284399Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss
- 2026-10-02T14:19:17.9309442Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss
- 2026-10-02T14:19:17.9309396Z ##[warning]boringcache/one save failed: Input does not meet YAML 1.2 "Core Schema" specification: fail-on-cache-miss

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Cold build | 0 | 163.0 | 163.0 | unmeasured | unmeasured | reuse not measured (1 refs planned) | [JSON](runs/1-boringcache-cold.json) |
| 1 | BoringCache | Warm build | 0 | 152.0 | 152.0 | unmeasured | unmeasured | reuse not measured (1 refs planned) | [JSON](runs/1-boringcache-warm.json) |

[Full records and checks](report.json)
