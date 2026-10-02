# zitadel-moon evaluation proposal

Status: reviewed source selection; execution is blocked by `case.json`.
No measurements or performance claims have been collected.

Source: [`zitadel/nextgen` at `faccf02136ff713718e103b18d4128e5a665d02e`](https://github.com/zitadel/nextgen/tree/faccf02136ff713718e103b18d4128e5a665d02e).
Inspect [.moon/workspace.yml](https://github.com/zitadel/nextgen/blob/faccf02136ff713718e103b18d4128e5a665d02e/.moon/workspace.yml) and
[apps/console/moon.yml](https://github.com/zitadel/nextgen/blob/faccf02136ff713718e103b18d4128e5a665d02e/apps/console/moon.yml) before activation.

Question: Does Moon's console build reuse remote task outputs across clean workers?

Preparation outside the comparison: corepack pnpm install --frozen-lockfile.
Proposed timed command: `corepack pnpm exec moon run console:build`.


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
