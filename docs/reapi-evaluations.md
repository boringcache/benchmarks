# Native gRPC cache evaluations

These four source-pinned evaluation drafts use the existing case contract. They
are blocked from execution and scheduling until their client, product release,
workflow, and output verification are qualified. They contain no measurements.

| Case | Workload | Reason to evaluate | Limitation |
| --- | --- | --- | --- |
| [zitadel-moon](../cases/zitadel-moon/proposal.md) | ZITADEL console assets | Existing Moon task graph and remote-cache configuration | Resolve its lockfile client version and record the instance-name change |
| [pants-jvm](../cases/pants-jvm/proposal.md) | Pants Java/Scala example | Native JVM compile, test, and package operations | Small correctness screen; upstream client differs from product qualification |
| [buck2-prelude](../cases/buck2-prelude/proposal.md) | Buck2 Rust/C++ examples | Native Buck2 action-cache use | Cargo compilation of Buck2 itself is a different workload |
| [msgpack-sbt](../cases/msgpack-sbt/proposal.md) | MessagePack Java tests | Upstream sbt 2.0.9 and a normal Java 21 CI matrix member | Remote-cache settings require a declared patch |

Moon documents REAPI action caching, CAS, SHA256, and gRPC support. Its configuration
also supports Depot. [Moon remote-cache documentation](https://moonrepo.dev/docs/guides/remote-cache).
sbt 2.x ships a gRPC remote-cache client and requires `addRemoteCachePlugin` plus
the endpoint setting. [sbt remote-cache documentation](https://www.scala-sbt.org/2.x/docs/en/reference/remote-cache-setup.html).

The cache-only REAPI candidate is the motivation for these cases. Its proof does not establish that
the currently pinned public Action/CLI supports these workloads. Product client
qualification remains in the product repository; this repository measures real
workload behavior after that gate passes.

Begin with `bazel-remote` as a protocol comparator. Compare providers only after
declaring equivalent cache-only behavior, supported digest/compression/instance
settings, source, outputs, client version, and storage semantics. Depot,
BuildBuddy, or another commercial arm needs its own authorized configuration;
the upstream repository's provider choice does not supply credentials or make
its previous runs comparable.

The comparison measures native build and remote reuse. Bootstrap downloads and
unrelated dependency preparation remain outside timing. Fresh workers must clear
local action results and outputs while retaining the intended remote seed.
Record native hit/miss evidence, output manifests, storage measurement source,
and whether uploads complete inside or outside the timed command. Follow
[the same process](process.md) used by maintained benchmarks.
