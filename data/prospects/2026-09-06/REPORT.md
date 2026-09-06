# Loomarr compiler-cache benchmark — 6 September 2026

**All eight benchmark jobs passed**, plus the separate affected Linux verification. Same upstream sources and four-ABI build as the earlier Gradle-only comparison. Both providers now cache Gradle task outputs and native C/C++ compilation with ccache.

| Provider | Cold job | Warm job | Warm build command | Warm Gradle build |
| --- | ---: | ---: | ---: | ---: |
| GitHub cache | 34:55 | 14:23 | 6:44 | 5:58 |
| BoringCache | 43:35 | 10:43 | 5:46 | 4:57 |

Whole-job times include setup and artifact checks. BoringCache's warm job was **25.5% shorter**; its build command was **14.3% shorter**. The cold job was **8:40 longer**. One observation per provider/phase; setup and runner variation contribute to the difference.

Both warm builds reused **1,000/1,000 compiler results** and **159/467 Gradle tasks**. BoringCache's 16 CMake build tasks totaled **25:50 cold → 1:04 warm**. Its earlier Gradle-only warm Gradle build took **22:23**, versus **4:57** with compiler caching. This is additional cache coverage in a separate cohort.

**Rolling: seed three commits before head, then each actual successor on a fresh runner.** These commits changed application/release files, with no C/C++ source changes; the compiler hits demonstrate retained native-dependency reuse.

| BoringCache | Seed | Head−2 | Head−1 | Head |
| --- | ---: | ---: | ---: | ---: |
| Whole job | 42:01 | 13:33 | 14:23 | 11:36 |
| Build command | 35:01 | 7:24 | 6:40 | 6:00 |
| Compiler hits / misses | 0 / 1,000 | 1,000 / 0 | 1,000 / 0 | 1,000 / 0 |

All builds verified four ABIs, 76 native libraries and 16 KiB alignment. The historical seed verifies an ephemeral signed bundle; successors preserve upstream's unsigned-artifact verification. Standard Ubuntu runners reported **4 CPUs**; native and Gradle workers remained **1**.

Production MCP matched all **six BoringCache jobs** to native Gradle/compiler lookup counts, with **zero cache errors or backend retries**. The fresh warm job wrote **zero bytes**. Compiler cache objects include manifests and results, so object lookups differ from compiler-call counts.

BoringCache 1.20.3 via GitHub OIDC, workspace `boringcache/benchmarks`; ccache 4.14 and HTTP helper 0.9. CMake launchers and Expo's documented precompiled-header settings were identical for both providers.

[Fresh runs](https://github.com/boringcache/benchmarks/actions/runs/34020980647) · [Rolling runs](https://github.com/boringcache/benchmarks/actions/runs/34021064665) · [Affected verification](https://github.com/boringcache/benchmarks/actions/runs/34021083856) · [Timings](results.json) · [Artifact checks](workload-results.json) · [MCP correlation](cache-correlation.json) · [Native task timings](task-timings.json) · [Source pins](sources.json) · [Rolling pins](rolling-sources.json)
