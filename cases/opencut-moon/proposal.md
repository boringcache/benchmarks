# opencut-moon

Status: native REAPI correctness screen implemented; hosted qualification pending.

The shared Moon configuration enables `experiments.casOutputsCache`: the pinned
Moon 2.3.3 uploads remote outputs through that cache path.

Source: [OpenCut-app/OpenCut at `e668010778568641babef2cc40be4703ae6916d6`](https://github.com/OpenCut-app/OpenCut/tree/e668010778568641babef2cc40be4703ae6916d6).

## Workload

The upstream web build is unchanged. The pinned revision has no lockfile; the payload adds a Bun 1.3.11 lockfile resolved on October 5, 2026. This is an explicit dependency-resolution change. Both providers use frozen installation against that file. The case retains upstream Moon 2.3.3.

Declared command: `moon run web:build`.

The case uses the shared `reapi-fresh-benchmark.yml` workflow, registry runner,
source verifier and canonical reporter. Tool installation and dependency
preparation run before timing. Required dependency tasks that the native client
runs again remain inside the command measurement.

## Cache and verification

BoringCache runs through `boringcache ci run` and `cache-registry --reapi-port`.
The CLI owns OIDC renewal, storage, cache publication and shutdown flushing.
Cold uses a fresh case/series/sample/run tag. Warm uses a separate worker and a
read-only registry. Native client result state is not transferred between workers.

The protocol comparator is bazel-remote 2.6.2. Its local store is transferred as a
GitHub artifact before the warm registry starts. That transfer is outside timing,
so this is a correctness screen, not an end-to-end provider performance comparison.
Registry startup, native command and shutdown durations are recorded separately.
Storage is unmeasured. No schedule or performance publication is enabled.

Warm qualification requires native remote-hit evidence, verified outputs matching
the cold hashes and successful registry shutdown. Failed runs and their logs are
retained. The initial screen uses one sample; repeat qualification uses the case's
two-sample declaration. Neither establishes a general performance advantage.

This temporary shared registry entrypoint can be replaced by the product adapter
without changing the source recipes or output checks.
