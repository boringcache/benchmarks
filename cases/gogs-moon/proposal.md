# Gogs / Moon

Status: source-pinned evaluation; execution is blocked by `case.json`.
No benchmark measurements have been collected.

Source: [gogs/gogs at `dbbd717e923694c36f41b0360515b4374bbe6ee0`](https://github.com/gogs/gogs/tree/dbbd717e923694c36f41b0360515b4374bbe6ee0).

Reviewed upstream files:

- [.moon/workspace.yml](https://github.com/gogs/gogs/blob/dbbd717e923694c36f41b0360515b4374bbe6ee0/.moon/workspace.yml)
- [moon.yml](https://github.com/gogs/gogs/blob/dbbd717e923694c36f41b0360515b4374bbe6ee0/moon.yml)
- [web/moon.yml](https://github.com/gogs/gogs/blob/dbbd717e923694c36f41b0360515b4374bbe6ee0/web/moon.yml)

## Workload

Pin Moon, Go and pnpm from the reviewed upstream environment. Prepare locked dependencies and generated sources before timing on Linux x86_64.

Proposed timed command: `moon run gogs:build-prod`.

The production task builds `.bin/gogs` and depends on `web:build`, which produces `public/dist`. The upstream command embeds the current time using `date`; record a patch that uses a fixed source timestamp in both provider arms. Dependency tasks remain in the graph: verify whether they execute inside the measured command and label that work explicitly.

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
