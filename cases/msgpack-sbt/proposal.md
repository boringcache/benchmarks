# msgpack-sbt

Status: two cold/warm samples passed for both providers.
[Recorded results](../../results/msgpack-sbt/registry-qualification-01/report.md).

Source: [msgpack/msgpack-java at `5c28fbad6cd360d8ea822df109830ae2517a7ae4`](https://github.com/msgpack/msgpack-java/tree/5c28fbad6cd360d8ea822df109830ae2517a7ae4).

## Workload

The source patch enables `addRemoteCachePlugin`. The payload sets the loopback endpoint from the runner environment and fixes the benchmark version to the upstream revision so synthetic preparation commits cannot change the cache key. Java 21 and upstream sbt 2.0.9 are retained. The normal `test` command remains; upstream uncached compilation wrappers are unchanged. Class outputs must exist and match the cold hashes.

Declared command: `./sbt --debug test`.

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
