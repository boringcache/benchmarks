# executorch-buck2

Status: native REAPI correctness screen implemented; hosted qualification pending.

Source: [pytorch/executorch at `5e21c13cc9e34fa2922d5708ba5962e3e365afdb`](https://github.com/pytorch/executorch/tree/5e21c13cc9e34fa2922d5708ba5962e3e365afdb).

## Workload

The upstream portable executor runner target and Buck2 2025-05-06 pin are retained. The payload adds a local execution platform with remote caching enabled and remote execution disabled. Source submodules retain upstream pins. Verification checks executable ELF output and cold/warm hashes; it does not run an exported model.

Declared command: `buck2 build //examples/portable/executor_runner:executor_runner --show-output`.

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
