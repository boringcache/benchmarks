# OBS Xcode direct qualification

Both providers completed the declared cold parent and changed-source builds at
signed harness `50f069f123cef134e307db653c853d39eee08404`, using CLI 1.33.0 for
BoringCache. Output checks, job conclusions, and post-step logs passed.

This is one screening sample per phase and provider. Cold build and reuse took
658.4 seconds with BoringCache and 656.9 seconds with Actions Cache. Changed-source
build and reuse took 193.7 seconds and 100.8 seconds respectively. BoringCache's
slower changed-source observation is retained. This sample does not establish a
general performance difference or its cause.

The declared timing covers cache restore/setup and the upstream
`Building obs-studio` log group. Dependency installation, CMake configuration,
queueing, and post-job cache save are excluded. Both providers used the pinned
parent `e7136951c052db9a74de853f2f0ec5d1bc8f6f4a` and child
`ef5814431c6af9061874470201d0b799bc84602b`, hosted macOS 26 ARM64, and image
`20260907.0351.1`. These matched recorded fields do not eliminate runner variance.

BoringCache's selected-tag byte observations were 983,997,286 and 985,937,000.
Actions Cache storage was unmeasured because the original reporting steps lacked
a GitHub token. No storage comparison is supported. The original phase records
remain unchanged; a workflow fix applies to future series.

The [structured report](report.json) includes every declared observation and
completion. The [evidence archive](evidence.md) was independently downloaded and
verified. Publication remains unreviewed; this is execution qualification rather
than a reviewed website claim or a ten-sample benchmark.
