# sbt warm builds recompile through BoringCache; restore memory after large archives

Date: 2026-10-09. Runs on CLI 1.40.2 unless noted. Evidence files are under `results/<tool>/<case>/<scope>/`.

## 1. sbt: BoringCache's remote cache does not serve compile results that another REAPI cache does

Case `sbt/lila` (lichess-org/lila, sbt 2.0.9, `sbt test;stage`), runner `github` (4 cores):

| Step | Commit | Change | BoringCache | GitHub Actions cache |
| --- | --- | --- | --- | --- |
| 0 (cold) | `fda69002` | — | 195 s | 206 s |
| 1 | `edbe956e` | 4 commits, 46 files, almost all `translation/dest/*.xml` | 335 s | 104 s |

sbt's own output at step 1:

| Lane | Compile batches | Sources compiled | Tests run |
| --- | --- | --- | --- |
| BoringCache (`boringcache sbt`, remote cache over REAPI) | 111 | 1,573 | 569 |
| GitHub Actions cache (sbt 2 local disk cache restored with actions/cache) | 4 | 169 | 46 |

A cold build compiles 113 batches, so under BoringCache step 1 recompiled nearly the whole build and reran every test suite.

BoringCache answered quickly (`boringcache-sbt-github-rolling-1-*.boringcache.jsonl`):

- 3,729 cache lookups: 2,966 hits, 763 misses.
- 5,410 REAPI calls from sbt: p95 2 ms, 3 s in total.
- The startup prefetch finished at 16.6 s; sbt's first request came at 60.5 s; every sbt read was served from the local cache.

### Local experiments: it is BoringCache, not sbt

lila at `fda69002`, macOS, sbt 2.0.9; every build first deleted all `target` directories, as a fresh CI checkout would.

1. **Per-run settings paths do not change sbt's keys.** With sbt's local disk cache kept, three `sbt compile` runs compiled nothing: one with default settings, and two each with a new `-Dsbt.global.base=/tmp/<uuid>/sbt -Dsbt.global.settings=/tmp/<uuid>` holding a `<uuid>.sbt` file. That is the shape the adapter injects (v1.40.2: `cli/src/commands/adapters/command/reapi.rs` lines 188–233, `reapi/material.rs` lines 111–150).
2. **sbt's remote cache restores compile results from another REAPI server.** With `Global / remoteCache := Some(uri("grpc://localhost:9092"))` pointing at `buchgr/bazel-remote-cache`, and no BoringCache involved:
   - a cold run with an empty local disk cache compiled 1,490 sources in 87 batches and filled bazel-remote;
   - a second run with `target` and the local disk cache both emptied, so the remote cache was the only source, compiled **3 sources in 1 batch**.

So sbt 2 restores compile outputs through a remote cache, and the per-run paths are not the cause. The 763 misses at step 1 are lookups a working remote cache would have hit.

### Next checks

- Run `boringcache sbt` twice at the same lila commit, emptying the local disk cache before the second run, and capture which REAPI calls miss (ActionCache `GetActionResult`, or CAS `FindMissingBlobs`, `BatchReadBlobs`, `ByteStream.Read`).
- Run the same pair against bazel-remote and compare: which action digests bazel-remote returns that BoringCache reports missing, and whether step 0 stored them.
- Candidates to rule in or out: action-cache entries written but not published in the tag version the next run reads; CAS blobs referenced by an action result but treated as missing; results rejected over output-file metadata.

## 2. Does `boringcache run` hold restore memory during the build? (unmeasured)

Case `cargo/zed-bundle`, lane `boringcache-archive` (`boringcache run --profile bundle`), Namespace 8 vCPU / 16 GB:

- Restoring the 24 GB `target` archive (92,588 files) peaked the CLI at **1,671–1,679 MB** (`process_peak_rss_bytes` in `archive_graph_phase`). The lowest available memory reported after a restore phase was 13,654 MB.
- `rustc` was then killed with SIGKILL compiling Zed's `project` crate at step 1, three times (runs 37928786080, 37930734681 and 37935222721; the first two are deleted on GitHub, their evidence files remain).
- The Namespace cache-volume lane, which runs no wrapper process, passed the same step on the same machine size.
- The CLI uses the default glibc allocator and never calls `malloc_trim`, so its RSS may stay near the peak while `boringcache run` waits on the build.

Next check: sample the `boringcache` process RSS during a large-restore build. If it stays near the peak, release restore memory before running the command (`malloc_trim(0)`, or dropping the restore buffers). The case now runs on Depot 8c / 32 GB, so it does not block rolling.

## Withdrawn

An earlier reading that warm builds stall on the startup prefetch was wrong. `cache_blob_read` events with `source=remote_fetch` include the prefetch's own downloads (`kv/prefetch.rs` line 374), and those finished early, at 8.7–16.6 s for sbt/lila and 5.1–26.9 s for bazel/grpc, while each build kept reading from the local cache until it ended.
