# Native gRPC cache evaluations

These eight source-pinned evaluations use the existing case contract. Five use
the shared native registry workflow. Moon, Pants and sbt have completed two
cold/warm samples per selected workload; Buck2 qualification is running. ZITADEL, Pants
JVM and Buck2 Prelude remain blocked drafts. None has an active schedule.

| Case | Workload | Reason to evaluate | Limitation |
| --- | --- | --- | --- |
| [opencut-moon](../cases/opencut-moon/proposal.md) | OpenCut web assets | Existing Moon build and CI graph | Moon 2.5.6 replaces upstream 2.3.3; web assets only |
| [gogs-moon](../cases/gogs-moon/proposal.md) | Gogs frontend | Upstream Moon web build | Web assets only; Go server compilation is outside this screen |
| [executorch-buck2](../cases/executorch-buck2/proposal.md) | ExecuTorch portable executor | Native C++ runtime and kernel compilation | Buck2 2025-06-01 replaces upstream 2025-05-06; executable checks do not run a model |
| [stackstorm-pants](../cases/stackstorm-pants/proposal.md) | StackStorm plugin tests | Existing Pants test CI job | Pack metadata unit tests only; service-dependent tests are outside this screen |
| [zitadel-moon](../cases/zitadel-moon/proposal.md) | ZITADEL console assets | Existing Moon task graph and remote-cache configuration | Resolve its lockfile client version and record the instance-name change |
| [pants-jvm](../cases/pants-jvm/proposal.md) | Pants Java/Scala example | Native JVM compile, test, and package operations | Small correctness screen; upstream client differs from product qualification |
| [buck2-prelude](../cases/buck2-prelude/proposal.md) | Buck2 Rust/C++ examples | Native Buck2 action-cache use | Cargo compilation of Buck2 itself is a different workload |
| [msgpack-sbt](../cases/msgpack-sbt/proposal.md) | MessagePack Java tests | Upstream sbt 2.0.9 and a normal Java 21 CI matrix member | Remote-cache plugin and stable benchmark version are explicit recipe changes |

OpenCut, ExecuTorch, StackStorm and MessagePack are the initial application
workloads. Gogs provides another Moon workload. The existing ZITADEL, Pants JVM
and Buck2 Prelude drafts retain their own source pins and correctness questions.
Nix uses a separate binary-cache protocol; its Zed and Helix cases are listed in
[tool coverage](tool-coverage.md).

Moon documents REAPI action caching, CAS, SHA256, and gRPC support. Its configuration
also supports Depot. [Moon remote-cache documentation](https://moonrepo.dev/docs/guides/remote-cache).
sbt 2.x ships a gRPC remote-cache client and requires `addRemoteCachePlugin` plus
the endpoint setting. [sbt remote-cache documentation](https://www.scala-sbt.org/2.x/docs/en/reference/remote-cache-setup.html).

The selected CLI release exposes the native REAPI registry endpoint. Protocol
fixtures remain in the product repository. These cases qualify selected OSS
workloads through that endpoint; they do not imply managed native Action modes.

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

## Shared native registry execution

OpenCut, Gogs, StackStorm, ExecuTorch and MessagePack now declare the shared
native registry correctness workflow. Their proposals record selected targets,
recipe changes and verification requirements. The two-sample reports for
[Gogs](../results/gogs-moon/registry-qualification-01/report.md),
[OpenCut](../results/opencut-moon/registry-qualification-01/report.md),
[StackStorm](../results/stackstorm-pants/registry-qualification-01/report.md) and
[MessagePack](../results/msgpack-sbt/registry-qualification-01/report.md) retain
each provider and phase. Buck2 qualification remains pending.
BoringCache uses a fresh remote tag and a read-only warm process;
bazel-remote transfers its store as an artifact outside timing. No performance
comparison or completed family qualification follows from implementation alone.
