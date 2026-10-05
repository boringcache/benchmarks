# Tool coverage

All cases use the same workspace, provider wrapper, and report format. A plan
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
| Nx | Storybook | Qualify rolling source and seed lineage |
| Turbo | n8n; PostHog plan | Qualify each selected workload and timing boundary |
| Bazel | gRPC C++ client and server | Complete the repaired three-provider cold/warm proof with the repository BuildBuddy secret |
| Native REAPI clients | Moon, Pants, Buck2, sbt evaluation drafts | Blocked pending released product/client compatibility and reviewed execution; see [evaluation plans](reapi-evaluations.md) |
| Nix | No active case | Add a pinned workload and correctness check before claiming coverage |
| Archive, Artifact, GHA compatibility service | No dedicated active comparison case | Define a separate workload when measuring these products; using archives or GitHub artifact uploads inside a build does not qualify all three |

Docker tool-cache injection is configured by the product plan. It is not another
benchmark adapter. Product support includes Bazel, ccache, Go, Gradle, Maven, Nx,
sccache, and Turbo; this repository does not yet qualify every injected family.
Cargo target mounts use the product's managed freshness behavior and can compose
sccache. Nix's daemon/store and macOS Xcode are not Linux Docker injection modes.
The new REAPI clients also need their own released-product qualification.

For a new tool or option, follow [the existing case process](process.md). Keep
product configuration in `.boringcache.toml`, pass the mode through the shared
wrapper, and add only the upstream recipe and output check the case needs.
Review a new Action input or changed evidence field once in the shared harness.
Retain raw product evidence even before reporting uses a new field. Run the
product-owned interface check and a declared cold/reuse series before scheduling.
No benchmark repository, installer, proxy lifecycle, or second report format is
needed for a new tool family.
