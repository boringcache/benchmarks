# Native adapter qualification

These diagnostic runs use retained CLI source `b26bccd2becbe87f0a800e3e690f19696dc9198f`
(`vcli-canary-b26bccd2becb`). The complete candidate came from Product CI
[c1953312](https://ci.boringbuild.dev/runs/c1953312-2d9e-4aee-8969-21f46ac2b6b0),
BoringCache Artifact `art_14d8222421d1a123ab25b729`. Linux and Windows E2E passed;
macOS E2E and the overall gate failed. This is benchmark qualification, not
release approval. Cadence activation remains held.

The downloaded representation matches
`131ffd674a10a61a769a1ce9ec97313aaaed8d201c66bd80ddc8890d7701aaab`.
All ten payload sizes and checksums match `CLI-CANDIDATE.json`; its checksum file
also matches the manifest. The Linux AMD64 binary was copied without rebuilding
to the [benchmark evidence release](https://github.com/boringcache/benchmarks/releases/tag/evidence-native-adapters-2026-10-05),
downloaded again, and verified against the pinned digest. Jobs install only that
exact Linux AMD64 payload. The existing Action supports `cli-version: skip` for
this preinstalled CLI; each series still records the exact candidate selector.

Moon (OpenCut and Gogs), Pants, Buck2 and sbt use their native managed CLI
commands. BoringCache owns endpoint configuration, read-only policy, publication,
and cleanup. The raw cache-registry invocation is removed. The bazel-remote
comparator retains its separate process lifecycle. Each fresh sample requires
remote hits and matching output hashes in its read-only replay.

Native BoringCache timing includes the complete managed command, including
setup and publication. Separate setup/save times are unmeasured. Comparator
phases retain their original timing boundary. These runs establish correctness;
they do not establish a provider performance ranking.

Zed and Deno keep their reviewed parent/child source pairs and release recipes.
Each compiler engine gets a separate declared series and cache scope. The first
screening uses compiler-only reuse: Deno `compiler-only`, Zed `sccache-only`
(the existing variant identifier). Zed's cold phase publishes a combined target
and compiler seed; its changed-source consumer selects compiler-only reuse.
Engine selection is shown in run and job names. Native tool versions are
sccache 0.17.0, Kache 0.28.1, and mbx 1.22.0. Archive digests are pinned.

A completed build alone does not establish compiler reuse. Review the original
CLI/engine evidence and post-step status for hits, misses, write errors, output
verification, and source lineage before marking an engine qualified. Failed or
cancelled runs remain observations. Each first screening has one sample; further
samples must use predeclared plans and fresh scopes.
