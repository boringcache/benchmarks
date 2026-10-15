# Benchmark follow-ups

The consolidated harness is running. Configuration is in `tools/`, `rolling.toml`, `runners.toml`, and `versions.toml`. Procedures are in [AGENTS.md](AGENTS.md).

## Added cases

| Case | Start | Build and lanes |
| --- | --- | --- |
| ccache/osquery | `6b8969bb09ba5d3c01277ad04e55b87b4021f934`, 2026-09-09 | Last first-parent master commit before [osquery/osquery#9104](https://github.com/osquery/osquery/issues/9104), opened 2026-09-14. Builds upstream's [Linux Release CI configuration](https://github.com/osquery/osquery/blob/6b8969bb09ba5d3c01277ad04e55b87b4021f934/.github/workflows/hosted_runners.yml) with toolchain 1.2.0, tests enabled, debug symbols enabled, and `nproc + 1` jobs. BoringCache ccache remote storage and GitHub Actions ccache archives run on Ubuntu 24.04, GitHub 4 vCPU. Both use upstream's `ccache.conf` and ccache 4.14.1; the archive lane keeps the default 5 GiB local limit. Both rebuild OpenSSL and configure from source. Only compiler outputs are cached; this case does not reproduce competition among upstream's OS, architecture and build-type cache keys. |

The issue's 38.29% hit-rate example comes from the selected commit's [Linux Release job](https://github.com/osquery/osquery/actions/runs/34361072629/job/102498037144): 1,821 hits in 4,756 calls, 2,935 misses, and three cleanups after restoring a cache. That job used ccache 4.5.1 on Ubuntu 22.04. The benchmark uses ccache 4.14.1 on Ubuntu 24.04 for both lanes, matching the harness's existing ccache setup.

## Remaining migration work

- Migrate the website's `Reporting::BenchmarkComparisons` reader from `data/latest/index.json` to the current report format. The old reader requires an `entries` array; the current report contains `rows` and `matched`. Keep `data/latest/` until the reader and its tests migrate together.
- Update the monorepo release-pin tooling and benchmark product contract for this repository's `versions.toml`, `.github/actions/phase/action.yml`, and current lane names. Verify those consumers before removing their compatibility assumptions.
- CLI canary comparisons are manual through `project.yml`, with `mode=fresh` and an exact `cli` tag. The removed hourly collector referred to archived repositories and supplied no coverage for this harness.

## Runner limits under review

| Case | Run | Finding |
| --- | --- | --- |
| Cargo Ferrum: experimental incremental lane | [Step 8, attempt 2](https://github.com/boringcache/benchmarks/actions/runs/38722414892) | The build and fuzz runs finished, but saving the target failed while writing archive chunks: `Disk quota exceeded (os error 122)`. SDK cleanup left 97 GiB available before allocating 12 GiB of swap. Diagnostics report a 75.2 GB target, including 12.5 GB of incremental state. The recorded phase took 3,813.308 s with exit status 1; no target cache was saved, so there is no incremental reuse measurement. The three regular lanes passed. |

## Upstream failures under review

| Case | Records | Finding |
| --- | --- | --- |
| sbt/lila: BoringCache lane, rolling steps 194, 195 and 209 | [194](https://github.com/boringcache/benchmarks/actions/runs/38344612372), [195](https://github.com/boringcache/benchmarks/actions/runs/38347319586), [209](https://github.com/boringcache/benchmarks/actions/runs/38587589423) | Scala 3.9.0 fails while loading `java/lang/invoke/SerializedLambda.class` from the JDK image: `newPosition > limit: (3077 > 1013)`, or a zero magic number for `Class$AnnotationData`. 3,077 is the superclass-field offset of `SerializedLambda` and 1,013 is the size of `Class$AnnotationData` in Temurin 21.0.12, which fits a shared class-file reader being reset while in use ([ReusableDataReader](https://github.com/scala/scala3/blob/3.9.0/compiler/src/dotty/tools/dotc/core/classfile/ReusableDataReader.scala), removed upstream in [scala/scala3#26481](https://github.com/scala/scala3/pull/26481)). The GHA lane passes the same commits; remote-cache hits change which compilations run concurrently. Archive restore finishes before compilation and does not touch the JDK. Keep rolling; recheck when Lichess moves to a Scala release with that change. |

## Removed lanes

| Lane | Date | Recorded outcome |
| --- | --- | --- |
| Bazel gRPC: Cachely | 2026-10-08 | Warm 1,702 s; cold 3,238 s in [run 37691560883](https://github.com/boringcache/benchmarks/actions/runs/37691560883). Earlier runs logged upload timeouts. |
| Xcode OBS: Bitrise | 2026-10-08 | The documented setup failed CMake configuration in [run 37761446458](https://github.com/boringcache/benchmarks/actions/runs/37761446458). [Default setup](https://github.com/boringcache/benchmarks/actions/runs/37768474822) and [disabled prefix mapping](https://github.com/boringcache/benchmarks/actions/runs/37769123380) retained the configuration and Swift build failures. |
| Zed: unpaired Namespace 8c lane; PostHog: Depot 4c and Namespace lanes | 2026-10-09 | The active comparisons use the runners in each case's `[runs]`. Historical records remain outside the reported lane selection. |
| Cargo and Nix Zed: Depot 4c lanes (BoringCache, on-demand, kache, Cachix) | 2026-10-13 | Removed for the Depot plan budget (2,000 runner minutes a month); these lanes used about 205 Depot minutes per step. Zed's upstream CI runs on Namespace. Historical records remain outside the reported lane selection. |
| PostHog: BoringCache and BoringCache plus on Depot 8c | 2026-10-13 | Moved to Depot 4c, nightly, so the Depot and Namespace runner lanes share the GitHub runners' 4-core size. The 8c series has 82 matched steps on CLI 1.41.0 in the records. |

## Restored lanes

| Lane | Date | Reason |
| --- | --- | --- |
| Xcode OBS: Bitrise, with new Bitrise lanes for Bazel gRPC and Gradle OpenTelemetry Java | 2026-10-13 | Bitrise Build Cache CLI [v3.17.4](https://github.com/bitrise-io/bitrise-build-cache-cli/releases/tag/v3.17.4) skips `-derivedDataPath` on target-only `xcodebuild` builds ([PR 592](https://github.com/bitrise-io/bitrise-build-cache-cli/pull/592)), the cause of the CMake configuration failure. The lanes use the default activation, without `--disable-prefix-mapping`. |
| PostHog: BoringCache and BoringCache plus on Namespace 4c, beside the Namespace builder | 2026-10-13 | Pairs a Namespace runner with the Namespace builder, as Depot 8c pairs with the Depot builder, while the Namespace trial lasts. The PostHog Namespace runner tags were deleted on 2026-10-09, so the first step back restores nothing. |
| Zed on Namespace 8c as its own case, `cargo/zed-namespace` | 2026-10-14 | GitHub's 4-vCPU x64 runners ran Zed on six CPU models, and CPU assignment decided close Zed results. The new case rolls the same commits from GitHub step 56 (`eb466341a`) on Namespace 8c, which the Namespace dashboard lists as 8 vCPU / 16 GB, with two level-matched pairs: BoringCache against Depot Cache (sccache WebDAV, [Depot docs](https://depot.dev/docs/cache/integrations/sccache)) and BoringCache plus against the Namespace cache volume ([nscloud-cache-action](https://namespace.so/docs/reference/github-actions/nscloud-cache-action)). Its plan tags are prefixed `zed-namespace-` so no GitHub-lane cache is shared. The Namespace lanes added to `cargo/zed` earlier on 2026-10-14 are removed before they ran. |
| Zed on Namespace: all four lanes on 4 vCPU / 16 GB, series 2 | 2026-10-14 | On 8 vCPU / 16 GB the Namespace cache-volume lane's rustc was killed (SIGKILL) while compiling `project`, while the three sccache lanes on the same shape finished. That lane runs plain cargo: `project` started at 16:02:07 and `editor` at 16:02:54, so the largest crates compiled at the same time. In the BoringCache lane `editor` started six minutes after `project`, consistent with sccache returning rustc output only when each compile ends, so cold sccache builds overlap less than plain cargo on the same machine. 8 vCPU / 32 GB exceeds this Namespace workspace's quota (largest shape 8x16), so the lanes run on `nscloud-ubuntu-24.04-amd64-4x16`: the memory per core of GitHub's 4-vCPU runners, where Zed's plain-cargo lane finishes. All four lanes use runner labels; the cache-volume lane adds a 100 GB volume. `rolling_series = 2` restarts the case at GitHub step 56 and leaves the 8-core seed builds out of the reported series. |
| Zed on Namespace: build diagnostics on all four lanes | 2026-10-14 | In series-2 steps 0–2 the BoringCache sccache lane and Depot Cache had the same compile requests, hits and misses, but sccache's average compile time per miss was 10%, 46% and 23% higher on the BoringCache lane, while its cache hits took 3 ms against Depot's 128 ms. Step 1 finished 7.4 minutes behind. The case now runs `cargo build --timings`, and the phase action samples `/proc/stat`, pressure stall information, memory and the cargo, rustc, sccache and boringcache processes every 5 s, and records the CPU family and model. Each lane uploads these as a `diagnostics-*` artifact for 14 days; they are not committed with the results. Remove after the cause is found. |
| Rust: an experimental incremental lane on Zed (Namespace) and Ferrum, seeded from BoringCache plus | 2026-10-15 | `boringcache-cargo-plus-incremental` runs the plus plan's entries with `CARGO_INCREMENTAL=1`, so the CLI keeps each profile's `incremental/` state in the target entry. It has no compiler cache: sccache 0.17.0 exits with "incremental compilation is prohibited" whenever `CARGO_INCREMENTAL` or `CARGO_BUILD_INCREMENTAL` is `1` ([run 38708200348](https://github.com/boringcache/benchmarks/actions/runs/38708200348)), and `1` is the only value that makes the CLI keep incremental state, so its `plus-incremental` plans drop `compiler-cache` and the adapter tag, and dependencies come from the restored target. It is experimental, so reports leave it out. Until it has a passing step, it restores the plus lane's current entries read-only through `boringcache cargo --phase restore` (the new lane `seed` key), then builds and saves under its own tags, so neither case starts from an empty cache and the plus lane's tags are never written. It measures whether rustc's incremental reuse shortens rebuilds of large workspace crates. Ferrum's sanitizer build spends 33 minutes in one crate of 50 MB of source, and the lane also measures restore and save time and the size of the incremental state. Build diagnostics now cover Ferrum too and record target and incremental directory sizes. Remove the lane when the comparison is done. |
| Zed on Namespace: incremental lane removed after its first reuse step | 2026-10-15 | On matched Zen 5 hosts with the swap profile ([run 38721452994](https://github.com/boringcache/benchmarks/actions/runs/38721452994)), the incremental lane's cargo build took 17m28s against BoringCache plus's 13m22s, used 3.35 GB of swap, and grew its target to 48.1 GB against 26.1 GB. Zed's release profile builds each crate as one codegen unit, so incremental state cannot skip code generation. The lane continues on Ferrum, whose sanitizer build uses 16 codegen units. |
| Zed on Namespace: the 4 vCPU / 16 GB lanes move to a runner profile with 16 GB of swap | 2026-10-15 | The incremental lane's first step that reused its state was killed for memory compiling `project` ([run 38715849087](https://github.com/boringcache/benchmarks/actions/runs/38715849087)): four rustc processes reached 13.6 GB, available memory fell to 0.57 GB and memory pressure to 76%, on a VM without swap. Plain cargo pipelines `project` with its dependents, and rustc also loads and writes incremental state. `namespace-4x16` now uses the profile `namespace-profile-zed-4x16-swap` (4 vCPU, 16 GB, Ubuntu 24.04, no cache volume, 16384 MB swap), so the BoringCache, plus, incremental and Depot Cache lanes keep one machine shape and their cache scopes. Swap is used only when memory runs out; the build sampler records it. The cache-volume lane keeps its own labelled runner without swap. |
| Ferrum: free the GitHub runner's preinstalled SDKs before the build | 2026-10-15 | Every Ferrum fuzz binary takes about 3.4 GB with the sanitizer and debug info, so the plus lane's target reached 76.6 GB during the fuzz runs. The incremental lane's 12.4 GB of state (4.7 GB test build, 7.7 GB sanitizer build) then filled the disk while linking `ocsp_response` ([run 38713898339](https://github.com/boringcache/benchmarks/actions/runs/38713898339)). The case removes Android, .NET, GHC and CodeQL first, as the Zed case does, for every lane and before the timer starts. |

## Restarted series

| Case | Restart | Reason |
| --- | --- | --- |
| Cargo Deno | Series 2, 2026-10-09 | CLI 1.40.2. |
| sbt Lichess and Play | Series 2, 2026-10-09 | CLI 1.41.0; Play's version pin moved to `version.sbt`. |
| ccache and Xcode OBS | Series 2, 2026-10-10 | Prerequisite installation moved into untimed preparation. |

The superseded records and raw evidence are available in [Git history](https://github.com/boringcache/benchmarks/tree/3e705f46e31638de5e323480445b29a92cce3df4/archive). They are not inputs to the current scheduler or report.

## Removed cases

On 2026-10-13: Cargo `zed-bundle`, which ran only on Depot 8c, for the Depot plan budget. Its definition is in [Git history](https://github.com/boringcache/benchmarks/tree/f024c932107a8ed40b333d07f419298926426043/tools/cargo/zed-bundle).

On 2026-10-09: Pants `pants-jvm` and `stackstorm`, moon `gogs` and `opencut`, sbt `msgpack-java`, Buck2 `buck2-prelude`, Docker `mastodon-streaming`, and Nix `helix`. The recorded reasons were low upstream activity, short builds, or replacement by a more active project. Measurements and detailed decisions are in the [previous plan](https://github.com/boringcache/benchmarks/blob/3e705f46e31638de5e323480445b29a92cce3df4/PLAN.md).

## Removed lanes

On 2026-10-14: PostHog `boringcache-registry` on GitHub amd64 and arm64, after [run 38542847273](https://github.com/boringcache/benchmarks/actions/runs/38542847273). Registry image transfers are a separate experiment from BuildKit cache measurements.
