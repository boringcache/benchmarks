# Additional native action evidence, 16 November 2026

This local qualification builds upstream Ninja through BoringCache ccache and
sccache. It checks additional action evidence beside existing compiler evidence.
It is separate from provider comparisons and does not measure a speed improvement.

The unreleased CLI binary SHA-256 is
`df37b6b35c68a0cd39ca79a75784b1d399f5ae1edea29198024f90b23492b467`.
The machine is macOS ARM64 with eight logical CPUs and concurrent qualification
work. Tools are ccache 4.14.3, ccache-storage-http 0.10.1 and sccache 0.17.0 from
the product's checksum-pinned requirements. The driver Ninja 1.13.1 was built
from upstream commit `79feac0f3e3bc9da9effc586cd5fea41e7550051`.

For each adapter, six invocations build four source-changing revisions, with
unchanged read-only builds after the first and last revisions. Two further
invocations rebuild the final revision with action evidence disabled and enabled.
Both rebuilds clean native outputs first and read the same populated cache tag.
The sixteen builds all succeed. Source revisions, outputs, executable hashes,
cache totals, evidence coverage and whole wrapped-command times are in
`result.json`. Source checkout, configuration and executable verification are
outside the timer. Each timing is one fixed-order observation on this shared host.

Configure each revision outside the timer:

```sh
cmake -S . -B build -G Ninja -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_MAKE_PROGRAM=/path/to/ninja \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
```

Use sccache as the launcher for that adapter. Enable the additional evidence in
the project configuration:

```toml
workspace = "boringcache/benchmarks"
[adapters.ccache.options]
ninja-log = "build/.ninja_log"
```

Use `adapters.sccache.options` for sccache. Remove that options section for the
disabled control. Invoke the same native command through each adapter:

```sh
boringcache ccache --workspace boringcache/benchmarks \
  --tag qual-native-additive-20261116-ccache --no-git --no-platform \
  --fail-on-cache-error --native-tool-evidence-json native.json \
  -- /path/to/ninja -C build
```

Unchanged phases and both paired rebuilds add `--read-only`. Each adapter uses
its own isolated tag. These measurements do not qualify fresh-runner remote
hits; existing local blob caches can serve reads. The qualification tags are
removed after collection.

The six rolling phases report 31, 0, 35, 15, 2 and 0 additional action groups per
adapter; the enabled paired rebuild adds 35. The sixteen exports contain 236
complete action records and 143 primary ccache compilation records. Sccache
retains aggregate compiler evidence. Each disabled/enabled pair has 33 compiler
hits, zero misses, equal primary outcomes, equal keyed lookup decisions and an
identical executable hash. Disabled collection is `not_requested`, not zero work.

`stored-verification.json` records exact readback of all 143 ccache compilation
records through `runs units`. One earlier lookup file remains pending with 131
declared records. Unchanged builds have no lookup file because they make no
compiler requests. Both paired lookup files parse and their decisions match.
The live server rejects the additional action-file kind, so the action records
here are local product exports, not proof of live storage of that new kind.
Unavailable evidence is never treated as zero. The historical
`native-ninja-2026-11-16` cohort used a superseded primary-source policy and does
not qualify this additional-file path.

`controls-additive.json` records ten further invocations: warm rebuild, compiler
failure, recovery, explicit recompaction and unchanged build for each adapter.
Both warm rebuilds have 33 hits and zero misses. Failed builds preserve exit 1;
automatic Ninja recompaction returns `ninja_log_rewritten`. Recovery observes
two actions, explicit recompaction reports the same gap, and the following
unchanged build reports zero new observations. A first harness assertion that
required partial evidence on failure was corrected to accept the documented
recompaction gap; the failed build was retained and was not rerun as a cold.

The JSON files under `evidence/` are common product exports and CLI record-reader
outputs. This repository implements no Ninja parser. Action durations can
overlap and do not identify per-action compiler hits, input-valid reuse keys,
dependencies, CPU use or saved build time. Compatible CLI and server releases
are required before scheduled benchmark plans can enable this option.
