# Benchmark configuration history

Current procedures and comparison limits are in [tools/README.md](tools/README.md).

## Removed lanes

| Lane | Date | Recorded outcome |
| --- | --- | --- |
| PostHog: BoringCache and BoringCache plus on Depot 4c and Namespace 4c, and the Namespace builder; Bazel gRPC and Cargo Zed: every-step read-only lanes | 2026-10-19 | GitHub runners stay the every-step baseline, and third-party runners run only the nightly read-only lanes under Restored lanes. PostHog's upstream CI does not use the Namespace builder, and gRPC's upstream CI runs on Kokoro with Google's remote build service rather than a runner vendor. Historical records remain outside the reported lane selection. |
| Rust: incremental experiments on Zed (Namespace) and Ferrum | 2026-10-15 | Removed at the user's request, including the experimental plans, result records and cache tags. Zed's [reuse run](https://github.com/boringcache/benchmarks/actions/runs/38721452994) was slower than plus; Ferrum's [seed run](https://github.com/boringcache/benchmarks/actions/runs/38722414892) could not save its target within the runner's disk quota. Regular compiler and plus comparisons continue. |
| Bazel gRPC: Cachely | 2026-10-08 | Warm 1,702 s; cold 3,238 s in [run 37691560883](https://github.com/boringcache/benchmarks/actions/runs/37691560883). Earlier runs logged upload timeouts. |
| Xcode OBS: Bitrise | 2026-10-08 | The documented setup failed CMake configuration in [run 37761446458](https://github.com/boringcache/benchmarks/actions/runs/37761446458). [Default setup](https://github.com/boringcache/benchmarks/actions/runs/37768474822) and [disabled prefix mapping](https://github.com/boringcache/benchmarks/actions/runs/37769123380) retained the configuration and Swift build failures. |
| Zed: unpaired Namespace 8c lane; PostHog: Depot 4c and Namespace lanes | 2026-10-09 | The active comparisons use the runners in each case's `[runs]`. Historical records remain outside the reported lane selection. |
| Cargo and Nix Zed: Depot 4c lanes (BoringCache, on-demand, kache, Cachix) | 2026-10-13 | Removed for the Depot plan budget (2,000 runner minutes a month); these lanes used about 205 Depot minutes per step. Zed's upstream CI runs on Namespace. Historical records remain outside the reported lane selection. |
| PostHog: BoringCache and BoringCache plus on Depot 8c | 2026-10-13 | Moved to Depot 4c, nightly, so the Depot and Namespace runner lanes share the GitHub runners' 4-core size. The 8c series has 82 matched steps on CLI 1.41.0 in the records. |

## Restored lanes

| Lane | Date | Reason |
| --- | --- | --- |
| PostHog, Cargo Zed and Docker Chroma: nightly read-only BoringCache plus lanes on GitHub 4c and the upstream's runner vendor (Depot 4c for PostHog, Namespace 4c for Zed, Blacksmith 4 vCPU for Chroma) | 2026-10-19 | GitHub runners are the every-step baseline. Each nightly lane reads the GitHub x64 BoringCache plus lane's rolling cache with `--read-only` and never saves, like one publishing runner with read-only builds on other runners. The GitHub reader separates the skipped save from the runner change. The report pairs each reader step with the GitHub lane's step at the same commit. |
| Xcode OBS: Bitrise, with new Bitrise lanes for Bazel gRPC and Gradle OpenTelemetry Java | 2026-10-13 | Bitrise Build Cache CLI [v3.17.4](https://github.com/bitrise-io/bitrise-build-cache-cli/releases/tag/v3.17.4) skips `-derivedDataPath` on target-only `xcodebuild` builds ([PR 592](https://github.com/bitrise-io/bitrise-build-cache-cli/pull/592)), the cause of the CMake configuration failure. The lanes use the default activation, without `--disable-prefix-mapping`. |
| PostHog: BoringCache and BoringCache plus on Namespace 4c, beside the Namespace builder | 2026-10-13 | Pairs a Namespace runner with the Namespace builder, as Depot 8c pairs with the Depot builder, while the Namespace trial lasts. The PostHog Namespace runner tags were deleted on 2026-10-09, so the first step back restores nothing. |
| Zed on Namespace 8c as its own case, `cargo/zed-namespace` | 2026-10-14 | GitHub's 4-vCPU x64 runners ran Zed on six CPU models, and CPU assignment decided close Zed results. The new case rolls the same commits from GitHub step 56 (`eb466341a`) on Namespace 8c, which the Namespace dashboard lists as 8 vCPU / 16 GB, with two level-matched pairs: BoringCache against Depot Cache (sccache WebDAV, [Depot docs](https://depot.dev/docs/cache/integrations/sccache)) and BoringCache plus against the Namespace cache volume ([nscloud-cache-action](https://namespace.so/docs/reference/github-actions/nscloud-cache-action)). Its plan tags are prefixed `zed-namespace-` so no GitHub-lane cache is shared. The Namespace lanes added to `cargo/zed` earlier on 2026-10-14 are removed before they ran. |
| Zed on Namespace: all four lanes on 4 vCPU / 16 GB, series 2 | 2026-10-14 | On 8 vCPU / 16 GB the Namespace cache-volume lane's rustc was killed (SIGKILL) while compiling `project`, while the three sccache lanes on the same shape finished. That lane runs plain cargo: `project` started at 16:02:07 and `editor` at 16:02:54, so the largest crates compiled at the same time. In the BoringCache lane `editor` started six minutes after `project`, consistent with sccache returning rustc output only when each compile ends, so cold sccache builds overlap less than plain cargo on the same machine. 8 vCPU / 32 GB exceeds this Namespace workspace's quota (largest shape 8x16), so the lanes run on `nscloud-ubuntu-24.04-amd64-4x16`: the memory per core of GitHub's 4-vCPU runners, where Zed's plain-cargo lane finishes. All four lanes use runner labels; the cache-volume lane adds a 100 GB volume. `rolling_series = 2` restarts the case at GitHub step 56 and leaves the 8-core seed builds out of the reported series. |
| Zed on Namespace: build diagnostics on all four lanes | 2026-10-14 | In series-2 steps 0–2 the BoringCache sccache lane and Depot Cache had the same compile requests, hits and misses, but sccache's average compile time per miss was 10%, 46% and 23% higher on the BoringCache lane, while its cache hits took 3 ms against Depot's 128 ms. Step 1 finished 7.4 minutes behind. The case now runs `cargo build --timings`, and the phase action samples `/proc/stat`, pressure stall information, memory and the cargo, rustc, sccache and boringcache processes every 5 s, and records the CPU family and model. Each lane uploads these as a `diagnostics-*` artifact for 14 days; they are not committed with the results. Remove after the cause is found. |
| Zed on Namespace: the 4 vCPU / 16 GB lanes use 16 GB of swap | 2026-10-15 | `namespace-4x16` uses the profile `namespace-profile-zed-4x16-swap` (4 vCPU, 16 GB, Ubuntu 24.04, no cache volume, 16384 MB swap) for the BoringCache, plus and Depot Cache lanes. The build sampler records swap use. The cache-volume lane keeps its own labelled runner without swap. |
| Ferrum: free the GitHub runner's preinstalled SDKs before the build | 2026-10-15 | Every Ferrum fuzz binary takes about 3.4 GB with the sanitizer and debug info, so the plus lane's target reached 76.6 GB during the fuzz runs. The case removes Android, .NET, GHC and CodeQL first, as the Zed case does, for every lane and before the timer starts. |

## Restarted series

| Case | Restart | Reason |
| --- | --- | --- |
| ccache osquery | Series 2, 2026-10-15 | Both lanes add `-Xclang -fno-pch-timestamp`, as documented for Clang PCH by ccache. The source remains `6b8969bb09ba5d3c01277ad04e55b87b4021f934`; step 0 starts with separate empty caches. Original-series records remain. The [last original-series run](https://github.com/boringcache/benchmarks/actions/runs/38742473859) was cancelled before starting this series. |
| Cargo Deno | Series 2, 2026-10-09 | CLI 1.40.2. |
| sbt Lichess and Play | Series 2, 2026-10-09 | CLI 1.41.0; Play's version pin moved to `version.sbt`. |
| ccache and Xcode OBS | Series 2, 2026-10-10 | Prerequisite installation moved into untimed preparation. |

The superseded measurements are available in [Git history](https://github.com/boringcache/benchmarks/tree/3e705f46e31638de5e323480445b29a92cce3df4/archive). They are not inputs to the current scheduler or report.

## Stopped ad hoc cases

| Case | Date | Outcome |
| --- | --- | --- |
| Docker Vocion | 2026-10-28 | Removed from the rolling schedule at the user’s request. Definitions and measurements remain in `tools/docker/vocion` and `results/docker/vocion`. Last completed publication run: [40686377453](https://github.com/boringcache/benchmarks/actions/runs/40686377453). Filesystem diagnostic [40676640825](https://github.com/boringcache/benchmarks/actions/runs/40676640825) stopped; its dedicated workflow is disabled. |
| Docker Eclipse OpenSOVD | 2026-10-28 | Removed from the rolling schedule at the user’s request. Definitions and measurements remain in `tools/docker/opensovd` and `results/docker/opensovd`. Last completed run: [40673476105](https://github.com/boringcache/benchmarks/actions/runs/40673476105). |
| Cargo Bevy Explorer | 2026-10-28 | Dropped because [the upstream repository](https://github.com/decentraland/bevy-explorer) is archived; GitHub API verified `archived: true` on this date. Removed from the rolling schedule. Definitions and measurements remain in `tools/cargo/bevy-explorer` and `results/cargo/bevy-explorer`. Last completed run: [40686361441](https://github.com/boringcache/benchmarks/actions/runs/40686361441). |

## Removed cases

On 2026-10-19: Cargo `zed-namespace`, which rolled its own series on Namespace 4c, replaced by the nightly Zed reader on Namespace 4c. Its definition is in [Git history](https://github.com/boringcache/benchmarks/tree/3a8abe91073cc636c281b9a2a54be6dc8fea1722/tools/cargo/zed-namespace).

On 2026-10-13: Cargo `zed-bundle`, which ran only on Depot 8c, for the Depot plan budget. Its definition is in [Git history](https://github.com/boringcache/benchmarks/tree/f024c932107a8ed40b333d07f419298926426043/tools/cargo/zed-bundle).

On 2026-10-09: Pants `pants-jvm` and `stackstorm`, moon `gogs` and `opencut`, sbt `msgpack-java`, Buck2 `buck2-prelude`, Docker `mastodon-streaming`, and Nix `helix`. The recorded reasons were low upstream activity, short builds, or replacement by a more active project. Measurements and detailed decisions are in the [previous plan](https://github.com/boringcache/benchmarks/blob/3e705f46e31638de5e323480445b29a92cce3df4/PLAN.md).

## Removed lanes

On 2026-10-14: PostHog `boringcache-registry` on GitHub amd64 and arm64, after [run 38542847273](https://github.com/boringcache/benchmarks/actions/runs/38542847273). Registry image transfers are a separate experiment from BuildKit cache measurements.
