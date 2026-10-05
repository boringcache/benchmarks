# Tool coverage

All cases use the same workspace and report format. Managed Action cases use
one provider wrapper; direct CLI evaluations declare that execution path. A plan
for a tool does not establish that every option or workload has been qualified.
Use the [series catalog](../data/latest/series.json) for recorded outcomes and
limitations. This inventory describes the case definitions as of October 5, 2026.

| Product path | Existing cases | Remaining work |
| --- | --- | --- |
| Docker / BuildKit | 47 Docker workloads; Chroma, Duckgres, Hugo, Immich, Linkerd2, Mastodon, n8n, PostHog, Qdrant | Qualify each selected recipe, variant, architecture, and rolling sequence |
| Cargo target and compiler reuse | Deno, Zed | Deno performance and verified rolling reuse remain open; keep compiler-only and target-plus-compiler results separate |
| sccache | Chroma, Mastodon, Zed; Docker projections | Qualify the selected native or Docker path separately |
| ccache / Xcode | OBS Studio; Immich also has a ccache experiment | Preserve platform and setup/timing differences |
| Go | Hugo Go; Docker Go projection | Keep native and Docker results separate |
| Gradle | OpenTelemetry Java | Qualify rolling source and seed lineage |
| Maven | Spring AI | Qualify rolling source and seed lineage |
| Nx remote cache | No active case | Storybook archives Nx directories; it does not exercise the native Nx remote-cache adapter |
| Turbo | n8n; PostHog plan | Qualify each selected workload and timing boundary |
| Bazel | gRPC C++ client and server | [One three-provider cold/warm sample passed](../results/grpc/local-outputs-01/report.md), including local output checks; BuildBuddy storage remains unmeasured; publication and rolling qualification remain open |
| Moon | [OpenCut](../cases/opencut-moon/proposal.md), [Gogs](../cases/gogs-moon/proposal.md), ZITADEL drafts | OpenCut and Gogs passed two native cold/warm samples each; ZITADEL remains a draft |
| Pants | [StackStorm](../cases/stackstorm-pants/proposal.md), Pants JVM drafts | StackStorm plugin tests passed two cold/warm samples; service-dependent tests and Pants JVM remain outside this qualification |
| Buck2 | [ExecuTorch](../cases/executorch-buck2/proposal.md), Buck2 Prelude drafts | Verify public targets, native action-cache use and output checks |
| sbt | [MessagePack Java](../cases/msgpack-sbt/proposal.md) | Two native cold/warm samples passed; managed product adapter remains separate |
| Nix | [Zed](../cases/zed-nix/proposal.md), [Helix](../cases/helix-nix/proposal.md) | Helix cold/warm screen passed; repeat checks and Zed qualification are running |
| Archive | Storybook's Nx cache directories | Qualify rolling source and seed lineage |
| Artifact, GHA compatibility service | No dedicated active comparison case | GitHub artifact uploads inside a benchmark do not qualify these BoringCache products |

Docker tool-cache injection is configured by the product plan. It is not another
benchmark adapter. Product support includes Bazel, ccache, Go, Gradle, Maven, Nx,
sccache, and Turbo; this repository does not yet qualify every injected family.
Cargo target mounts use the product's managed freshness behavior and can compose
sccache. Nix's daemon/store and macOS Xcode are not Linux Docker injection modes.
The selected [REAPI cases](reapi-evaluations.md) use one shared native registry workflow.
Moon, Pants and sbt have retained two-sample correctness results. Buck2
qualification is running; the remaining drafts stay blocked.
The Nix cases use one shared fresh workflow and the public Nix product mode;
Helix has retained screening results. The Cachix cache name and token are repository
configuration. No new schedules are enabled. Each family has a pinned OSS
workload; definitions and workflows do not establish measured coverage.
MessagePack keeps its existing case ID and pin.

For a new tool or option, follow [the existing case process](process.md). Keep
product configuration in `.boringcache.toml`, pass the mode through the shared
wrapper, and add only the upstream recipe and output check the case needs.
Review a new Action input or changed evidence field once in the shared harness.
Retain raw product evidence even before reporting uses a new field. Run the
product-owned interface check and a declared cold/reuse series before scheduling.
No benchmark repository, installer, proxy lifecycle, or second report format is
needed for a new tool family.
