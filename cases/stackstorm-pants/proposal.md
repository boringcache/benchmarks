# StackStorm / Pants

Status: source-pinned evaluation; execution is blocked by `case.json`.
No benchmark measurements have been collected.

Source: [StackStorm/st2 at `9824de4dfd0c869869e310dee729308f398ad83a`](https://github.com/StackStorm/st2/tree/9824de4dfd0c869869e310dee729308f398ad83a).

Reviewed upstream files:

- [pants.toml](https://github.com/StackStorm/st2/blob/9824de4dfd0c869869e310dee729308f398ad83a/pants.toml)
- [.github/workflows/test.yaml](https://github.com/StackStorm/st2/blob/9824de4dfd0c869869e310dee729308f398ad83a/.github/workflows/test.yaml)

## Workload

Use upstream Pants 2.25.0 and Python 3.11 for the plugin test workload. Prepare locked dependencies and the upstream MongoDB, RabbitMQ and Redis services before timing on Linux x86_64.

Proposed timed command: `pants test pants-plugins/::`.

This selects the existing Pants plugin-test CI job. The full StackStorm unit and integration suites are separate workloads. Service versions and configuration must match between providers; inspect the selected tests for external state before enabling remote result reuse.

## Comparison

Start with two cold builds and their identical-source warm replays per provider.
Compare BoringCache with `bazel-remote` using the same source, client, runner,
outputs and local execution. Declare endpoint settings and configuration patches
before execution. Keep remote execution disabled.

Record cache setup/restore, the declared command, upload completion, native
hit/miss evidence, output checks and provider storage sources. Missing storage
remains unmeasured. Failed observations remain in the series.

Follow [the shared case process](../../docs/process.md). The case has no schedule
or published results. `case.json` lists the remaining activation checks.
