# Benchmark follow-ups

The consolidated harness is running. Configuration is in `tools/`, `rolling.toml`, `runners.toml`, and `versions.toml`. Procedures are in [AGENTS.md](AGENTS.md).

## Added cases

| Case | Start | Build and lanes |
| --- | --- | --- |
| ccache/osquery | `6b8969bb09ba5d3c01277ad04e55b87b4021f934`, 2026-09-09 | Last first-parent master commit before [osquery/osquery#9104](https://github.com/osquery/osquery/issues/9104), opened 2026-09-14. Builds upstream's [Linux Release CI configuration](https://github.com/osquery/osquery/blob/6b8969bb09ba5d3c01277ad04e55b87b4021f934/.github/workflows/hosted_runners.yml) with toolchain 1.2.0, tests enabled, debug symbols enabled, and `nproc + 1` jobs. Series 2 adds the documented Clang PCH cache flag `-Xclang -fno-pch-timestamp` to both lanes. BoringCache ccache remote storage and GitHub Actions ccache archives run on Ubuntu 24.04, GitHub 4 vCPU. Both use upstream's `ccache.conf` and ccache 4.14.1; the archive lane keeps the default 5 GiB local limit. Both rebuild OpenSSL and configure from source. Only compiler outputs are cached; this case does not reproduce competition among upstream's OS, architecture and build-type cache keys. |

The issue's 38.29% hit-rate example comes from the selected commit's [Linux Release job](https://github.com/osquery/osquery/actions/runs/34361072629/job/102498037144): 1,821 hits in 4,756 calls, 2,935 misses, and three cleanups after restoring a cache. That job used ccache 4.5.1 on Ubuntu 22.04. The benchmark uses ccache 4.14.1 on Ubuntu 24.04 for both lanes, matching the harness's existing ccache setup.

In the original series, the [preflight](https://github.com/boringcache/benchmarks/actions/runs/38727149684), [step 0](https://github.com/boringcache/benchmarks/actions/runs/38727970681) and [step 1](https://github.com/boringcache/benchmarks/actions/runs/38732134849) passed both lanes. Every record from these runs has `exit_status = 0` and `output_ok = true`. Step 0 populated both caches; step 1's archive lane restored `ccache-osquery-gha-github-rolling-0` and saved the step-1 key. BoringCache's step-1 native ccache statistics report 1,821 hits in 4,756 compilations (38.29%), 2,935 misses, no cache errors and no failed blob uploads. Remote key lookup hits are a separate measurement from reused compilations.

| Step | Lane | Seconds | CPU, 4 vCPU |
| --- | --- | ---: | --- |
| 0 | BoringCache | 1452.793 | AMD EPYC 9V45 |
| 0 | GitHub Actions cache | 2367.452 | AMD EPYC 7763 |
| 1 | BoringCache | 1970.607 | Intel Xeon Platinum 8370C |
| 1 | GitHub Actions cache | 1637.991 | AMD EPYC 9V74 |

The [cache inspection](https://github.com/boringcache/benchmarks/actions/runs/38741412878) recovered the GitHub lane's cumulative counters from its saved step-1 archive: 9,512 calls, 1,821 hits, 7,691 misses and zero cleanups, with 4.0 GiB stored against a 5 GiB limit. Subtracting step 0's 4,756 misses gives the same step-1 compilation reuse as BoringCache: 1,821 hits and 2,935 misses (38.29%). Neither provider's first reuse result demonstrates eviction.

Comparing CMake's compile commands at the two commits finds 627 changed commands; four are unbuilt examples. The remaining 623 differ only in `OSQUERY_VERSION`, `OSQUERY_BUILD_VERSION` and `OSQUERY_BUILD_SDK_VERSION`. Upstream derives these from `git describe` and exports them through [public compile definitions](https://github.com/osquery/osquery/blob/6b8969bb09ba5d3c01277ad04e55b87b4021f934/osquery/utils/info/CMakeLists.txt#L41). Step 1 changes only a macOS test, but these definitions change Linux cache keys. Joining the configured object paths to the 4,756 actual compilation lines gives these groups, which exactly match the native hit/miss counts and remote key lookup counts:

| Step-1 compilation group | Commands |
| --- | ---: |
| Changed version definitions | 623 |
| Unchanged PCH-generation commands | 12 |
| Unchanged commands consuming PCH | 2300 |
| Unchanged commands without PCH | 1821 |

The [pinned Linux reproduction](https://github.com/boringcache/benchmarks/actions/runs/38744274916) uses the generated Makefile recipes, including dependency flags, for the AWS core PCH and one EC2 source file. Repeating in the same workspace reuses both compilations, including after moving to step 1. Recreating the build directory and updating checkout timestamps without changing contents causes both to miss and changes the PCH SHA-256. The debug log reports that the PCH includes `aws/core/external/cjson/cJSON.h` with a new mtime. Adding `-Xclang -fno-pch-timestamp` through `CMAKE_CXX_FLAGS` makes the PCH identical and both compilations hit after another recreation. The [ccache manual](https://ccache.dev/manual/4.14.1.html#_precompiled_headers) requires that flag for Clang PCH; [its manifest validation](https://github.com/ccache/ccache/blob/v4.14.1/src/ccache/core/manifest.cpp#L405-L412) rejects changed include mtimes without it. Series 2 adds this flag to the common build command for both lanes; the original series retains upstream's flags. A local Apple Clang regression with ccache 4.14 verified that changing an included header's contents, while preserving its size and mtime, rebuilds the PCH and consumer and changes the executable's result; subsequent unchanged compilations hit.

An isolated unused-version-macro test with the pinned Linux toolchain gives two misses with ccache's upstream `depend_mode = true`, one miss and one preprocessed hit with depend mode disabled, and two misses with sccache 0.17.0. Sccache's identical-arguments control hits. Switching tools alone does not remove the version-definition invalidation.

The [sccache PCH comparison](https://github.com/boringcache/benchmarks/actions/runs/38744923446) runs the same two AWS Makefile recipes with sccache 0.17.0. After recreating the build directory and updating checkout timestamps, sccache rebuilds the PCH but reuses the EC2 object. With `-Xclang -fno-pch-timestamp`, both tools reuse both compilations and preserve the PCH SHA-256. These probes cover two compilations; whole-build sccache performance remains unmeasured.

| Fresh-checkout probe | PCH generation | EC2 object |
| --- | --- | --- |
| ccache, upstream flags | Miss | Miss |
| sccache 0.17.0, upstream flags | Miss | Hit |
| ccache, PCH timestamp flag | Hit | Hit |
| sccache 0.17.0, PCH timestamp flag | Hit | Hit |

The [series-2 first reuse](https://github.com/boringcache/benchmarks/actions/runs/38755781425) passed both lanes. Native ccache evidence reports 4,133 hits and 623 misses in 4,756 compilations (86.90%), recovering the 2,312 PCH-related misses. The remaining miss count matches the changed version-definition group. Timed phases took 1,262.661 s for BoringCache on Xeon 8573C and 1,417.298 s for the archive lane on Xeon 8370C; the CPU difference prevents attributing that gap to storage alone. The archive restored series-2 step 0 and saved step 1, but its native counters were not retained.

BoringCache prefetched 9,512 blobs / 800,888,349 bytes in 4.931 s. All 8,266 successful build-time blob reads were local, with 551 ms summed local blob-read duration and no demand downloads. These timings exclude ccache hashing, storage-helper transport and other handler work. CMake configuration took 421 s and cloned 121 submodules, including a 175 s libcryptsetup checkout; the archive lane spent 472.5 s configuring and 160 s on that checkout. The final local cache read was at 15:13:22 UTC; compilation and linking finished at 15:25:06 UTC. Around 85–87%, build-message timestamps were at most 4.437 s apart. The run does not retain process CPU or pressure evidence, so proxy/compiler resource contention remains unmeasured. Both osquery lanes now collect the existing five-second CPU, memory, I/O-pressure and process samples as 14-day diagnostics, including process wait channels and build/source-preparation processes. The build command, cache scope and rolling series are unchanged.

The [series-2 second reuse](https://github.com/boringcache/benchmarks/actions/runs/38760868616) passed both lanes at `935173f3df6f64d58cacca840ef7a7937eecdb60`. BoringCache again reports 4,133 native hits and 623 misses. Its EPYC 7763 runner took 1,586.285 s; the archive lane's EPYC 9V45 took 865.021 s. The uncached OpenSSL build took 101.388 s against 50.979 s, and BoringCache's first blob-upload URL request occurred after OpenSSL completed. The 1,685 EC2 object build-message timestamps span 48.767 s against 27.188 s; their span includes ccache processing and build scheduling, not just cache reads. The CPU assignment and the slower uncached work prevent attributing this run's gap to the adapter.

This run prefetched 9,512 blobs / 800,880,532 bytes in 6.423 s. Every successful build-time blob read was local (8,266 reads, p95 recorded blob-read duration 1 ms, maximum 10 ms); all remote blob downloads finished at 15:38:24 UTC. Local cache reads ended at 15:47:12 UTC, while compilation and linking finished at 16:04:31 UTC. Final publication drain took 6.584 s. Build messages around 85–87% were at most 6.558 s apart. A genuine 101 s output gap occurred during the uncached OpenSSL build at 33%, and an 80 s gap occurred while cloning the AWS SDK during configuration. These timestamps distinguish application work from an apparent pause in the GitHub log display. This run predates the new sampler, so compiler/proxy CPU and memory contention remain unmeasured.

## Remaining migration work

## Upstream failures under review

| Case | Records | Finding |
| --- | --- | --- |
| sbt/lila: both lanes, intermittent class-file loading failures | [194](https://github.com/boringcache/benchmarks/actions/runs/38344612372), [195](https://github.com/boringcache/benchmarks/actions/runs/38347319586), [209](https://github.com/boringcache/benchmarks/actions/runs/38587589423) | Scala 3.9.0 fails while loading `java/lang/invoke/SerializedLambda.class` from the JDK image: `newPosition > limit: (3077 > 1013)`, or a zero magic number for `Class$AnnotationData`. 3,077 is the superclass-field offset of `SerializedLambda` and 1,013 is the size of `Class$AnnotationData` in Temurin 21.0.12, which fits a shared class-file reader being reset while in use ([ReusableDataReader](https://github.com/scala/scala3/blob/3.9.0/compiler/src/dotty/tools/dotc/core/classfile/ReusableDataReader.scala), removed upstream in [scala/scala3#26481](https://github.com/scala/scala3/pull/26481)). GHA also fails with class-file loading errors at [step 228](https://github.com/boringcache/benchmarks/actions/runs/38763375844); both lanes fail at [step 232](https://github.com/boringcache/benchmarks/actions/runs/38775829151), and BoringCache fails at [step 233](https://github.com/boringcache/benchmarks/actions/runs/38777726983). These failures affect both providers and are consistent with the upstream reader race; cache-dependent compilation concurrency remains a hypothesis. Archive restore finishes before compilation and does not touch the JDK. Keep rolling; recheck when Lichess moves to a Scala release with that change. |

## Harness failures under review

| Case | Records | Finding |
| --- | --- | --- |
| Docker/PostHog: plus lanes | [Step 189](https://github.com/boringcache/benchmarks/actions/runs/38885710081) | The frozen plus Dockerfile omitted upstream's `agent-contracts` COPY, so frontend builds failed while base lanes passed. Preparation now copies the checked-out Dockerfile and applies only the two Turbo cache changes from `start_sha`. The patch applies at `start_sha`, upstream fix `13ff07ce8`, and step 189. An Actions build with this harness change remains to be verified. |
| Cargo/ferrum-fuzz: plus lanes, runner disk capacity | [Step 16](https://github.com/boringcache/benchmarks/actions/runs/38802077476), [17](https://github.com/boringcache/benchmarks/actions/runs/38812938227), [29](https://github.com/boringcache/benchmarks/actions/runs/38881014353) | In steps 16–29, twelve GHA plus job logs show `No space left on device` during linking, and twelve BoringCache plus job logs show `Disk quota exceeded` while staging the target archive. Freeing the preinstalled SDKs did not provide enough disk space. GHA plus logs for steps 20 and 26 return `BlobNotFound`, so those two failures remain unclassified. Keep the records; a runner-capacity change must preserve the same machine and build command across lanes. |

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
| PostHog and Cargo Zed: nightly read-only BoringCache plus lanes on GitHub 4c and the upstream's runner vendor (Depot 4c for PostHog, Namespace 4c for Zed) | 2026-10-19 | GitHub runners are the every-step baseline. Each nightly lane reads the GitHub x64 BoringCache plus lane's rolling cache with `--read-only` and never saves, like one publishing runner with read-only builds on other runners. The GitHub reader separates the skipped save from the runner change. The report pairs each reader step with the GitHub lane's step at the same commit. |
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

The superseded records and raw evidence are available in [Git history](https://github.com/boringcache/benchmarks/tree/3e705f46e31638de5e323480445b29a92cce3df4/archive). They are not inputs to the current scheduler or report.

## Removed cases

On 2026-10-19: Cargo `zed-namespace`, which rolled its own series on Namespace 4c, replaced by the nightly Zed reader on Namespace 4c. Its definition is in [Git history](https://github.com/boringcache/benchmarks/tree/3a8abe91073cc636c281b9a2a54be6dc8fea1722/tools/cargo/zed-namespace).

On 2026-10-13: Cargo `zed-bundle`, which ran only on Depot 8c, for the Depot plan budget. Its definition is in [Git history](https://github.com/boringcache/benchmarks/tree/f024c932107a8ed40b333d07f419298926426043/tools/cargo/zed-bundle).

On 2026-10-09: Pants `pants-jvm` and `stackstorm`, moon `gogs` and `opencut`, sbt `msgpack-java`, Buck2 `buck2-prelude`, Docker `mastodon-streaming`, and Nix `helix`. The recorded reasons were low upstream activity, short builds, or replacement by a more active project. Measurements and detailed decisions are in the [previous plan](https://github.com/boringcache/benchmarks/blob/3e705f46e31638de5e323480445b29a92cce3df4/PLAN.md).

## Removed lanes

On 2026-10-14: PostHog `boringcache-registry` on GitHub amd64 and arm64, after [run 38542847273](https://github.com/boringcache/benchmarks/actions/runs/38542847273). Registry image transfers are a separate experiment from BuildKit cache measurements.
