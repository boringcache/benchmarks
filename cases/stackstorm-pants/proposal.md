# stackstorm-pants

Status: two cold/warm samples passed for both providers.
[Recorded results](../../results/stackstorm-pants/registry-qualification-01/report.md).

Source: [StackStorm/st2 at `9824de4dfd0c869869e310dee729308f398ad83a`](https://github.com/StackStorm/st2/tree/9824de4dfd0c869869e310dee729308f398ad83a).

## Workload

This screen selects `pants-plugins/pack_metadata/target_types_test.py`, a plugin test file that does not require MongoDB, RabbitMQ or Redis services. Pants 2.25.0 and Python 3.11.14 are pinned. Test reports must contain tests and no failures or errors. Full StackStorm service tests are outside this screen.

The command selects pytest from the existing `pants-plugins` lockfile and disables
root conftest inference for this isolated plugin test. The normal global pytest
resolve selects the service lockfile, whose unpinned Orquesta Git dependency no
longer matches its retained hash. This screen does not regenerate or relax that
service lockfile. The full command is recorded in `payload/reapi-recipe.json`.

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
