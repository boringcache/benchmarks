# Preserved failed preparation evidence

Both exports were downloaded from the [archive release](https://github.com/boringcache/benchmarks/releases/tag/evidence-obs-preparation-2026-10-02),
checked against their archive digests, extracted, and verified against their
file manifests and resource inventories. Each contains seven verified files
and no gaps within its declared run-resource scope.

- BoringCache: [original run 37063464018](https://github.com/boringcache/benchmarks/actions/runs/37063464018), [bundle](https://github.com/boringcache/benchmarks/releases/download/evidence-obs-preparation-2026-10-02/benchmarks-37063464018.tar).
  SHA-256: `5aec5b72aedf003c0f71a98fd85abdec7a463a79b801d14073b5382223ceb82a`.
- Actions Cache: [original run 37063467317](https://github.com/boringcache/benchmarks/actions/runs/37063467317), [bundle](https://github.com/boringcache/benchmarks/releases/download/evidence-obs-preparation-2026-10-02/benchmarks-37063467317.tar).
  SHA-256: `d4b0215eef1e74e7707f77b7d732de6250c37df2c9c64e6637bffa6f399ffbb0`.

Both runs failed before build, cache setup, and output verification. Preserving
them does not qualify timing, correctness, or storage claims. The replacement
series has a separate plan and identity.
