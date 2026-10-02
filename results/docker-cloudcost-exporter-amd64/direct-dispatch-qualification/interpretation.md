# Docker direct dispatch qualification

The predeclared AMD64 cloudcost-exporter cold and warm builds passed recipe
fidelity, declared output behavior, and preserved completion checks. The direct
dispatch response includes the exact run ID. It used the signed
`benchmark-consolidation-2026-10-02` harness tag and CLI v1.33.0.

This is a single-provider correctness proof with one sample. The declared output
is neither loaded nor pushed. It does not verify a runnable loaded image,
establish a timing or storage advantage, or qualify the other Docker cases and
architectures. [evidence.md](evidence.md) links the original run and the
independently downloaded and verified archive.

[cache-telemetry.json](cache-telemetry.json) retains bounded cache-side evidence.
The warm job served 16 Docker cache objects with zero misses or cache errors.
BuildKit reported eight cached and 29 executed steps across both builds. The
Go compile step executed again; the upstream recipe embeds build-time metadata,
so a pinned source alone does not fix every effective input.

Object counts are not compiler hit rates. Cache-side durations can overlap and
must not be added into a wall-clock claim. Storage remains unmeasured. Fresh
cache identity is recorded, but the retained managed OCI inventory does not
prove that every underlying object was absent before the seed. This series
does not qualify rolling execution or a provider comparison.
