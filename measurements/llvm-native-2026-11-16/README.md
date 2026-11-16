# LLVM native build controls, 16 November 2026

This experiment measures a native Clang build with a local ccache. It is separate
from rolling provider results. The source commit, machine, flags, timed commands,
output identity and exclusions are in `result.json`. Each seed and compiler-warm
arm ran once. The two unchanged-build reads use the seeded build directory.

The host uses Clang 18 and lld 18 on ARM64, targeting `clang`, with precompiled
headers disabled. The rolling case uses different host tools, architecture and
targets. These numbers do not compare cache providers or represent that case.

The seed took 779.788 seconds with 9 existing cache hits and 3,121 misses; it
was not an empty-cache cold run. A newly configured build directory using its local
compiler cache took 19.722 seconds, plus 17.511 seconds for configuration. ccache
reported 2,227 direct hits, 903 preprocessed hits, zero cacheable misses and one
unsupported code directive. The resulting executable matched the seed SHA256.
Output verification is outside the timed build.

To repeat, check out the recorded upstream commit, install the recorded tools,
set the three cache environment variables and substitute local absolute paths in
the CMake command. Start with an empty build directory. The recorded seed reused a cache from the
preceding cohort; an empty cache gives a separate cold measurement. Run CMake and
Ninja, record the executable hash, then run Ninja twice unchanged. Move the build
directory aside, preserving the cache and source tree. Run CMake at the original
build path, zero ccache statistics, run the same Ninja command, and compare the
executable hash. Read statistics with `ccache --print-stats --format=json`.
The raw warm Ninja log contains one invocation; its edge durations overlap.

A preceding cohort with default precompiled headers had almost no cacheable
compilations. It is excluded from this compiler-warm comparison. Local internal
build-state diagnostics and infrastructure records are kept outside this
benchmark measurement.
