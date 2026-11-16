# Native Ninja evidence, 16 November 2026

This historical candidate qualification builds upstream Ninja at four source-changing revisions
through BoringCache ccache and sccache. It is not a provider comparison or a
measurement of a restore/build speed improvement. These records are separate
from the rolling provider results.

The CLI reports version 1.48.2 and contains an unreleased native-evidence change.
Its binary SHA-256 is recorded in result.json. That candidate selected Ninja
as its primary work source. The current additive candidate preserves compiler
records and adds separate build-action evidence; these older readbacks do not
qualify that additional file path. The machine is macOS ARM64 with
eight logical CPUs. Tools are ccache 4.14.3, ccache-storage-http 0.10.1, sccache
0.17.0 and Ninja 1.13.1, downloaded from the product's checksum-pinned tool
requirements. The driver Ninja is built from upstream tag v1.13.1, commit
79feac0f3e3bc9da9effc586cd5fea41e7550051.

For each adapter, the source starts at b9551f14affeec26b42663410da41967dc166c50,
then advances through the three revisions recorded in result.json. Each sequence
contains a cold build, an unchanged read-only build, three changed-source builds
and a final unchanged read-only build. Each adapter uses its own isolated cache
tag. Builds use the ordinary authenticated workspace and real compiler-cache
backends. This local cohort does not test a fresh runner or establish that warm
reads came from remote storage rather than the CLI's existing local blob cache.

Configure each revision outside the build timer:

```sh
cmake -S . -B build -G Ninja -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_MAKE_PROGRAM=/path/to/ninja \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
```

Use sccache as the launcher for that adapter. The project configuration is:

```toml
workspace = "boringcache/benchmarks"
[adapters.ccache.options]
ninja-log = "build/.ninja_log"
```

Use adapters.sccache.options for sccache. Invoke each build with its adapter:

```sh
boringcache ccache --workspace boringcache/benchmarks \
  --tag qual-native-rolling-20261116-ccache --no-git --no-platform \
  --fail-on-cache-error --native-tool-evidence-json native.json \
  -- /path/to/ninja -C build
```

Unchanged phases add --read-only. Each output executable must run --version;
its output and SHA-256 are retained. result.json times the whole wrapped command,
including cache setup and evidence delivery; it excludes configuration, source
checkout and executable verification. Times were sampled once in fixed order.

Both sequences report 31, 0, 35, 15, 2 and 0 successful native command groups.
The 166 complete records were read back with runs units and match the local
export by ID, label, duration, attributes and native position. Each evidence file
is the product's common export or its existing record-reader output. There is
no Ninja parser in this repository.

Native action timings can overlap. They do not identify compiler-cache hits,
input-valid result keys, dependency chains, CPU use or saved build time. Compiler
hit/miss totals remain separate. This cohort qualifies rolling collection for
this workload; it does not enable the option in scheduled rolling plans before
a compatible CLI canary or release is available.
