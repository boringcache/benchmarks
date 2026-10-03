# Preserved OBS Xcode evidence

The [durable release](https://github.com/boringcache/benchmarks/releases/tag/evidence-obs-xcode-2026-10-02)
preserves [BoringCache run 37063471110](https://github.com/boringcache/benchmarks/actions/runs/37063471110)
and [Actions Cache run 37063474452](https://github.com/boringcache/benchmarks/actions/runs/37063474452).
Both ran from signed harness `50f069f123cef134e307db653c853d39eee08404`.

| Run | Bundle bytes | SHA-256 | Verified files | Gaps |
| --- | ---: | --- | ---: | ---: |
| 37063471110 | 590848 | `d1b342fadf7c9d3bb561fa84829b11cde4a7b90a5710d5ccc6f81142d0c4b492` | 11 | 0 |
| 37063474452 | 551424 | `96a08a7bd4e57db69820bd77169440b1e9f2cd3845835a53c0f27e6cb068f9a2` | 9 | 0 |

Uploaded archives were downloaded independently, checked against their archive
digests, extracted, and verified against file manifests and resource inventories.
The scope covers these runs' available attempts, jobs, logs, artifacts, commit
metadata, and workflows. It does not audit the whole original repository.

Original phase files are preserved without replacing missing storage values.
Output and completion checks passed. The [interpretation](interpretation.md)
retains the negative changed-source observation and the one-sample and storage
limitations. Preservation does not approve publication or repository deletion.
