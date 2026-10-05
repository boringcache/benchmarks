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

## Initial dispatches

| Case | Series | Run |
| --- | --- | --- |
| opencut-moon | native-reapi-01 | [37376751453](https://github.com/boringcache/benchmarks/actions/runs/37376751453) |
| gogs-moon | native-reapi-01 | [37376755061](https://github.com/boringcache/benchmarks/actions/runs/37376755061) |
| stackstorm-pants | native-reapi-01 | [37376758991](https://github.com/boringcache/benchmarks/actions/runs/37376758991) |
| executorch-buck2 | native-reapi-01 | [37376762709](https://github.com/boringcache/benchmarks/actions/runs/37376762709) |
| msgpack-sbt | native-reapi-01 | [37376766204](https://github.com/boringcache/benchmarks/actions/runs/37376766204) |
| zed | native-sccache-01 | [37376769643](https://github.com/boringcache/benchmarks/actions/runs/37376769643) |
| zed | native-kache-01 | [37376772894](https://github.com/boringcache/benchmarks/actions/runs/37376772894) |
| zed | native-mbx-01 | [37376777074](https://github.com/boringcache/benchmarks/actions/runs/37376777074) |
| deno | native-sccache-01 | [37376780672](https://github.com/boringcache/benchmarks/actions/runs/37376780672) |
| deno | native-kache-01 | [37376784408](https://github.com/boringcache/benchmarks/actions/runs/37376784408) |
| deno | native-mbx-01 | [37376787731](https://github.com/boringcache/benchmarks/actions/runs/37376787731) |

## First completed observations

OpenCut Moon, Gogs Moon, StackStorm Pants, ExecuTorch Buck2 and MsgPack sbt completed one cold and
read-only warm sample on both BoringCache and bazel-remote. Warm records report
remote hits and verified matching outputs. Completion checks passed, and the
original logs and artifacts were archived and downloaded again for verification.
This is one correctness sample per case, not performance qualification.

Zed `native-mbx-01` failed before compilation because mbx 1.22.0 rejects Cargo's
`--config` before the subcommand. The failure and its logs remain archived.
The new `native-mbx-02` series moves `build` before `--config` in the reviewed
Cargo layer plans; both argument orders load the same explicit configuration
in a local compile probe. The pinned mbx binary forwards the revised arguments
to Cargo. Source revisions, configuration path, targets and packages are unchanged.
The replacement [Zed mbx run 37377947724](https://github.com/boringcache/benchmarks/actions/runs/37377947724) reached its primary build step with the revised arguments.
The compiler-cache observations are still running; successful cold publication
and changed-source reuse remain unverified. Cadence activation remains held.
