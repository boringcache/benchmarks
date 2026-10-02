# pants-jvm evaluation proposal

Status: reviewed source selection; execution is blocked by `case.json`.
No measurements or performance claims have been collected.

Source: [`pantsbuild/example-jvm` at `675ee75d36f2c1b096b0def51efcfffd02bd1251`](https://github.com/pantsbuild/example-jvm/tree/675ee75d36f2c1b096b0def51efcfffd02bd1251).
Inspect [pants.toml](https://github.com/pantsbuild/example-jvm/blob/675ee75d36f2c1b096b0def51efcfffd02bd1251/pants.toml) and
[.github/workflows/pants.yaml](https://github.com/pantsbuild/example-jvm/blob/675ee75d36f2c1b096b0def51efcfffd02bd1251/.github/workflows/pants.yaml) before activation.

Question: Does Pants reuse JVM compilation and packaging through its native gRPC cache client?

Preparation outside the comparison: Bootstrap the pinned Pants 2.31.0 launcher, JDK, and dependency downloads.
Proposed timed command: `pants check test package ::`.


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
