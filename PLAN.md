# Benchmark follow-ups

The consolidated harness is running. Configuration is in `tools/`, `rolling.toml`, `runners.toml`, and `versions.toml`. Procedures are in [AGENTS.md](AGENTS.md).

## Remaining migration work

## Removed lanes

| Lane | Date | Recorded outcome |
| --- | --- | --- |
| Bazel gRPC: Cachely | 2026-10-08 | Warm 1,702 s; cold 3,238 s in [run 37691560883](https://github.com/boringcache/benchmarks/actions/runs/37691560883). Earlier runs logged upload timeouts. |
| Xcode OBS: Bitrise | 2026-10-08 | The documented setup failed CMake configuration in [run 37761446458](https://github.com/boringcache/benchmarks/actions/runs/37761446458). [Default setup](https://github.com/boringcache/benchmarks/actions/runs/37768474822) and [disabled prefix mapping](https://github.com/boringcache/benchmarks/actions/runs/37769123380) retained the configuration and Swift build failures. |
| Zed: unpaired Namespace 8c lane; PostHog: Depot 4c and Namespace lanes | 2026-10-09 | The active comparisons use the runners in each case's `[runs]`. Historical records remain outside the reported lane selection. |

## Restarted series

| Case | Restart | Reason |
| --- | --- | --- |
| Cargo Deno | Series 2, 2026-10-09 | CLI 1.40.2. |
| sbt Lichess and Play | Series 2, 2026-10-09 | CLI 1.41.0; Play's version pin moved to `version.sbt`. |
| ccache and Xcode OBS | Series 2, 2026-10-10 | Prerequisite installation moved into untimed preparation. |

The superseded records and raw evidence are available in [Git history](https://github.com/boringcache/benchmarks/tree/3e705f46e31638de5e323480445b29a92cce3df4/archive). They are not inputs to the current scheduler or report.

## Removed cases

On 2026-10-09: Pants `pants-jvm` and `stackstorm`, moon `gogs` and `opencut`, sbt `msgpack-java`, Buck2 `buck2-prelude`, Docker `mastodon-streaming`, and Nix `helix`. The recorded reasons were low upstream activity, short builds, or replacement by a more active project. Measurements and detailed decisions are in the [previous plan](https://github.com/boringcache/benchmarks/blob/3e705f46e31638de5e323480445b29a92cce3df4/PLAN.md).
