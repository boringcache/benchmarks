# OpenCut / Moon

Status: source-pinned evaluation; execution is blocked by `case.json`.
No benchmark measurements have been collected.

Source: [OpenCut-app/OpenCut at `e668010778568641babef2cc40be4703ae6916d6`](https://github.com/OpenCut-app/OpenCut/tree/e668010778568641babef2cc40be4703ae6916d6).

Reviewed upstream files:

- [.prototools](https://github.com/OpenCut-app/OpenCut/blob/e668010778568641babef2cc40be4703ae6916d6/.prototools)
- [.moon/toolchains.yml](https://github.com/OpenCut-app/OpenCut/blob/e668010778568641babef2cc40be4703ae6916d6/.moon/toolchains.yml)
- [apps/web/moon.yml](https://github.com/OpenCut-app/OpenCut/blob/e668010778568641babef2cc40be4703ae6916d6/apps/web/moon.yml)
- [.github/workflows/bun-ci.yml](https://github.com/OpenCut-app/OpenCut/blob/e668010778568641babef2cc40be4703ae6916d6/.github/workflows/bun-ci.yml)

## Workload

Use upstream Moon 2.3.3 and Bun 1.3.11. Install the locked dependencies before timing on Linux x86_64.

Proposed timed command: `moon run web:build`.

The upstream web task runs `bun run build` and declares `apps/web/dist`. CI runs the wider `moon ci` graph; this case selects only the web build. Do not run the deploy task.

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
