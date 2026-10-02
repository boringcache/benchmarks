# buck2-prelude evaluation proposal

Status: reviewed source selection; execution is blocked by `case.json`.
No measurements or performance claims have been collected.

Source: [`facebook/buck2` at `865ebd7af358a96baa455d7456c5cde1a3960c7d`](https://github.com/facebook/buck2/tree/865ebd7af358a96baa455d7456c5cde1a3960c7d).
Inspect [examples/with_prelude/.buckconfig](https://github.com/facebook/buck2/blob/865ebd7af358a96baa455d7456c5cde1a3960c7d/examples/with_prelude/.buckconfig) and
[.github/workflows/build_buck2.yml](https://github.com/facebook/buck2/blob/865ebd7af358a96baa455d7456c5cde1a3960c7d/.github/workflows/build_buck2.yml) before activation.

Question: Does Buck2 reuse Rust and C++ actions through a cache-only gRPC backend?

Preparation outside the comparison: Install a checksum-pinned Buck2 client and the example toolchains outside timing.
Proposed timed command: `buck2 build rust/... cpp/... -v=2`.
Run from examples/with_prelude. Building Buck2 itself with Cargo does not exercise its gRPC action cache.

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
