# Product issues found by the benchmark on 2026-10-10

Date: 2026-10-10. Runs on CLI 1.40.1 unless noted. Evidence files are under `results/<tool>/<case>/<scope>/`, or under `archive/obs-studio-series-1/` for OBS.

## 1. A full storage cap skips cache saves without failing the build, and the session summary calls it clean

Case `gradle/opentelemetry-java`, lane `boringcache-gradle` on `github`, rolling step 10 (run 37806607850, job 113412546638). The plan sets `fail-on-cache-error = true`.

The job log:

```
16:12:10 warning: Skipping cache uploads: Workspace Cache storage cap has been reached: 500 GB of the 500 GB allowance is stored or reserved for uploads in progress, and this upload needs 494 Bytes.
16:19:04 warning: Skipped cache save for 171 cache object(s) in this session: Workspace Cache storage cap has been reached: 500 GB of the 500 GB allowance is stored or reserved for uploads in progress
```

The evidence (`boringcache-gradle-github-rolling-10-37806607850.boringcache.jsonl`) has 205 `cache_blobs_upload_urls` responses with HTTP 507. The command exited 0, so the record shows `exit_status` 0 and `output_ok` true.

The session summary disagrees with itself:

| Field | Value |
| --- | --- |
| `backend_api.total_error_count` | 205, all `cache_blobs_upload_urls` |
| `oci.oci_engine_blob_writethrough_failure_count` | 166 |
| `classification.bottleneck.evidence` | `errors` 0, `write_errors` 0, `write_degraded` 0 |
| `classification.cache_temperature` | `errors` 0, state `warm_mixed` |

Gradle reported 556 tasks from cache at step 9, 341 at step 10 and 382 at step 11, the step after the skipped save.

The workspace hit the cap twice (2026-10-08 15:53–16:14 and 22:44 to 02:12 on 2026-10-09 UTC). 213 BoringCache records from those windows carry 507s on upload URLs, and 208 of them exited 0.

Two product problems:

1. **`fail-on-cache-error = true` does not cover a rejected save.** The CLI printed warnings and exited 0. Whether a storage cap should fail the build is a product decision, but a plan that asks to fail on cache errors expects a save that stored nothing to count, or at least to be reported as a failed save rather than a warning.
2. **The classification ignores the backend errors it sits next to.** Anything that reads the classification instead of the raw counters would call this session error-free.

## 2. ccache sessions are classified as having no cache reads

Case `ccache/obs-studio`, lane `boringcache-ccache` on `github-26`, rolling series 1 step 21 (run 37827716906):

| Source | Reads |
| --- | --- |
| `native_tool` (`ccache --print-log-stats --format=json`) | 579 hits and 4 misses of 583 cacheable compiles; `remote_storage_read_hit` 1,158 |
| `kv_lookup` | `kv_lookup_ccache_published_fast_hit` 1,158, `kv_lookup_ccache_after_refresh_miss` 8 |
| `local_cache.blob_read` | 1,158 local reads, 1,270 remote reads (203 MB) |
| `classification` | adapter `runtime`; `bottleneck.state` and `cache_temperature.state` `no_cache_reads`, hits 0, misses 0, `likely_reason` `no_restore_or_lookup_work` |

All 29 series 1 records of this lane have the same classification. The Xcode lane on the same project is classified `hot` on 28 of its 30 records, and Cargo's sccache classification matches its native counters, so the gap looks specific to the ccache adapter: the classifier does not read ccache's KV lookups or native counters.

CLI 1.41.0 does the same: OBS series 2 step 1 (run 38045662482) reported 596 hits and 3 misses from ccache, and the classification still says `no_cache_reads` with 0 hits.
