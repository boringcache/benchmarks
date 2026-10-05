# ExecuTorch / Buck2

Status: source-pinned evaluation; execution is blocked by `case.json`.
No benchmark measurements have been collected.

Source: [pytorch/executorch at `5e21c13cc9e34fa2922d5708ba5962e3e365afdb`](https://github.com/pytorch/executorch/tree/5e21c13cc9e34fa2922d5708ba5962e3e365afdb).

Reviewed upstream files:

- [.buckconfig](https://github.com/pytorch/executorch/blob/5e21c13cc9e34fa2922d5708ba5962e3e365afdb/.buckconfig)
- [.ci/docker/ci_commit_pins/buck2.txt](https://github.com/pytorch/executorch/blob/5e21c13cc9e34fa2922d5708ba5962e3e365afdb/.ci/docker/ci_commit_pins/buck2.txt)
- [examples/portable/executor_runner/targets.bzl](https://github.com/pytorch/executorch/blob/5e21c13cc9e34fa2922d5708ba5962e3e365afdb/examples/portable/executor_runner/targets.bzl)

## Workload

Use the upstream Buck2 pin 2025-05-06, reviewed C++ and Python toolchains, and pinned submodules. Generate one fixed input model and prepare dependencies before timing on Linux x86_64.

Proposed timed command: `buck2 build //examples/portable/executor_runner:executor_runner --show-output`.

The portable executor target compiles the runtime and portable kernels. The proposed public target spelling must pass a clean local build before activation. CMake source-list generation alone does not exercise Buck2 action-cache reuse.

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
