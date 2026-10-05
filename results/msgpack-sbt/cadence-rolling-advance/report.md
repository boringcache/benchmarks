# msgpack-sbt: cadence-rolling-advance

Question: Does sbt reuse MessagePack compilation and test results on a clean worker?

Measured scope: Native command and registry startup after dependency preparation; registry shutdown is recorded separately. The bazel-remote store is transferred as a GitHub artifact outside timing. This screen does not compare end-to-end provider performance. Rolling runs use the same measurement boundary. Comparator cache transfer is outside build timing; rolling reuse requires retained seed and native hit evidence.

Observations: 1/2 recorded; 0 failed; 1 missing.

Completion checks: missing or failed.

Publication: unreviewed.

| Phase | Provider | Successful observations | Storage median (bytes) | Storage observations |
| --- | --- | ---: | ---: | ---: |
| Changed-source build | BoringCache | 1 | unmeasured | 0 |

Comparison checks:

- Rolling seed and changed-source sequence are unverified.
- This series does not declare a comparison of provider performance.

Run 37323136088 failed completion checks:

- Workflow concluded failure
- bazel-remote msgpack-sbt commit: failure
- msgpack-sbt rolling report: failure

Missing observations:

- Sample 1, bazel-remote, Changed-source build

## Observations

| Sample | Provider | Phase | Cache setup/restore (s) | Build (s) | Build and cache reuse (s) | Storage (bytes) | Storage source | Cache | Record |
| ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | BoringCache | Changed-source build | 0.10089654600000131 | 24.936086543999977 | 25.03698308999998 | unmeasured | unmeasured | hit | [JSON](runs/1-boringcache-commit.json) |

[Full records and checks](report.json)
