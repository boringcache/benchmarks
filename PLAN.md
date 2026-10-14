# Benchmark follow-ups

The consolidated harness is running. Configuration is in `tools/`, `rolling.toml`, `runners.toml`, and `versions.toml`. Procedures are in [AGENTS.md](AGENTS.md).

## Remaining migration work

- Migrate the website's `Reporting::BenchmarkComparisons` reader from `data/latest/index.json` to the current report format. The old reader requires an `entries` array; the current report contains `rows` and `matched`. Keep `data/latest/` until the reader and its tests migrate together.
- Update the monorepo release-pin tooling and benchmark product contract for this repository's `versions.toml`, `.github/actions/phase/action.yml`, and current lane names. Verify those consumers before removing their compatibility assumptions.
- CLI canary comparisons are manual through `project.yml`, with `mode=fresh` and an exact `cli` tag. The removed hourly collector referred to archived repositories and supplied no coverage for this harness.

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
| Zed: BoringCache plus on Namespace 8c, beside the Namespace cache volume | 2026-10-14 | Pairs BoringCache plus with Namespace's cache volume ([nscloud-cache-action](https://namespace.so/docs/reference/github-actions/nscloud-cache-action)) on 8-core runners, where Zed's upstream CI runs, while the Namespace trial lasts. Both lanes cache the Cargo registry, git checkouts and target directory. The Zed Namespace 8c tags were deleted on 2026-10-09, so the first step back restores nothing; the cache volume's first step is its seed. |

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
