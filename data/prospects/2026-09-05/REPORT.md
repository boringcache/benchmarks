# Benchmark summary — 5 September 2026

**48 jobs completed successfully across six repositories:** 24 fresh comparisons and 24 rolling builds. Times below are **whole-job minutes:seconds**, including setup, caching, the workload and artifact checks. Repository names link to the runs.

**Fresh comparisons**

One cold and one dependent warm job per provider, using the same pinned source on separate Ubuntu 24.04 runners. BoringCache warm jobs were read-only.

| Repository | GitHub cold → warm | BoringCache cold → warm | Result |
| --- | ---: | ---: | --- |
| [WaterUI](https://github.com/boringcache/benchmarks/actions/runs/33973996116) | 38:17 → 11:06 | 47:19 → 11:19 | 1,735 tests passed; warm job 13s slower. |
| [adorsys](https://github.com/boringcache/benchmarks/actions/runs/33973996178) | 13:23 → 5:14 | 12:41 → 3:08 | 324 tests passed; warm job 40.1% shorter. |
| [Ferrum Edge](https://github.com/boringcache/benchmarks/actions/runs/33984066894) | 30:59 → 26:04 | 39:00 → 8:50 | 24,049 tests passed; warm job 66.1% shorter. |
| [Cadence](https://github.com/boringcache/benchmarks/actions/runs/33973996120) | 3:09 → 1:28 | 1:53 → 1:09 | Docker image layers reused; warm job 19s shorter. |
| [dotCMS](https://github.com/boringcache/benchmarks/actions/runs/33973996156) | 4:20 → 4:10† | 4:02 → 1:10 | 18/19 Nx tasks restored; archive baseline invalid. |
| [Loomarr](https://github.com/boringcache/benchmarks/actions/runs/33974184466) | 31:51 → 24:44 | 27:27 → 26:04 | Four-ABI Android checks passed; warm job 80s slower. |

† Nx rejected the restored GitHub archive and rebuilt. This is a successful build with an invalid warm-cache baseline; no provider speedup ratio is claimed.

Ferrum and adorsys benefited from retained Cargo target state. Ferrum's cold job cost 8:01 more. Results are single observations; build-state retention and test-time variation both affect the differences.

**Rolling builds**

BoringCache only: seed at three commits before the pinned head, then build each real successor in order on fresh runners. All four jobs restore and publish the same rolling cache cohort.

| Repository | Seed: head−3 | Head−2 | Head−1 | Head |
| --- | ---: | ---: | ---: | ---: |
| [WaterUI](https://github.com/boringcache/benchmarks/actions/runs/33985627704) | 42:23 | 12:35 | 17:34 | 9:54 |
| [adorsys](https://github.com/boringcache/benchmarks/actions/runs/33985627750) | 13:21 | 6:15 | 3:08 | 3:09 |
| [Ferrum Edge](https://github.com/boringcache/benchmarks/actions/runs/33985627694) | 30:41 | 27:45 | 28:16 | 26:32 |
| [Cadence](https://github.com/boringcache/benchmarks/actions/runs/33985627716) | 1:51 | 1:30 | 1:54 | 1:09 |
| [dotCMS](https://github.com/boringcache/benchmarks/actions/runs/33985627773) | 4:18 | 1:13 | 1:23 | 1:21 |
| [Loomarr](https://github.com/boringcache/benchmarks/actions/runs/33985627719) | 34:28 | 29:55 | 29:36 | 31:41 |

WaterUI's dependency-graph change served 2,926 compiler hits / 112 misses; its test set changed from 1,788 to 1,735 across the sequence. Ferrum still rebuilt its application crate after every code/version change. Cadence and dotCMS had unchanged measured inputs, so their rolling results demonstrate continued reuse. Full per-job test and artifact results are linked below.

**Cache evidence and storage**

Production MCP matched all **36 BoringCache jobs** to their native cache counts and archive restores: **zero cache errors**, with zero writes from all fresh warm jobs.

At 21:04 UTC, MCP verified WaterUI's **20.41 GB of compressed snapshot payloads**, including the original **6.90 GB** cache retained for over five hours. Payloads overlap and exclude compiler storage. This supports retention; the full [upstream eviction scenario](https://github.com/water-rs/waterui/issues/328) was not reproduced.

Workspace storage: **42.83 GB logical / 26.83 GB after catalog deduplication** at 21:02 UTC, against a 100 GiB target. The separate physical-object counter was **21.00 GB**, last refreshed at 19:23 UTC; it lags the runs.

BoringCache 1.20.3, GitHub OIDC, existing boringcache/benchmarks workspace. Native Cargo for Rust, Docker image construction/loading for Cadence, Nx for dotCMS and Gradle for Loomarr. Cold runs used new lookup tags in the shared content store.

[Run timings](results.json) · [Workload results](workload-results.json) · [MCP correlation](cache-correlation.json) · [Storage snapshot](storage-summary.json) · [Archive inventory](archive-inventory.json) · [Source pins](sources.json) · [Rolling source pins](rolling-sources.json) · [Run manifest](runs.json)
