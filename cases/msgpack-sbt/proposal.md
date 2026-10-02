# msgpack-sbt evaluation proposal

Status: reviewed source selection; execution is blocked by `case.json`.
No measurements or performance claims have been collected.

Source: [`msgpack/msgpack-java` at `5c28fbad6cd360d8ea822df109830ae2517a7ae4`](https://github.com/msgpack/msgpack-java/tree/5c28fbad6cd360d8ea822df109830ae2517a7ae4).
Inspect [project/build.properties](https://github.com/msgpack/msgpack-java/blob/5c28fbad6cd360d8ea822df109830ae2517a7ae4/project/build.properties) and
[.github/workflows/CI.yml](https://github.com/msgpack/msgpack-java/blob/5c28fbad6cd360d8ea822df109830ae2517a7ae4/.github/workflows/CI.yml) before activation.

Question: Does sbt 2.0.9 reuse MessagePack compilation through its native gRPC client?

Preparation outside the comparison: Install Java 21 and download launcher and dependencies outside timing.
Proposed timed command: `./sbt test`.


Start with two cold/warm observations per provider. `bazel-remote` is an
open-source protocol comparator; any later Depot or BuildBuddy comparison
requires a separate declared series with its configuration and storage scope.
Keep execution local in both arms; remote execution is outside this question.
Use the same source, client, toolchain, outputs, and clean-worker policy.

Declare and verify configuration patches before execution. Keep installation
and product proxy lifecycle in the CLI/Action. Do not copy the product's
client qualification framework into this repository. Candidate protocol proof
is not a released-client guarantee.

Follow [the case process](../../docs/process.md) to remove each blocker,
register the workflow, validate, prepare, declare a series, execute, preserve
evidence, and review the report. These drafts have no suite membership.
