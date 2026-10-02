# Hugo Go direct dispatch qualification

The two predeclared samples completed all eight observations and passed output,
source, runner-environment, product-version, and preserved post-step checks.
Both dispatch responses include exact run IDs. They used the signed
`benchmark-consolidation-2026-10-02` harness tag and CLI v1.33.0. This qualifies
the direct fresh-workflow path for this case.

The median build and cache reuse measurements were 76 seconds cold and 18 seconds
warm for BoringCache, and 79.5 seconds cold and 17 seconds warm for Actions Cache.
The [generated report](report.md) retains every observation. The earlier
[wrapper qualification](../wrapper-qualification/interpretation.md), where
BoringCache was slower, remains a separate series. Two measurements per phase
and provider do not establish a publication-quality advantage.

The metric includes measured cache setup/restore and Hugo's upstream build
entrypoint, including its dependency work. Post-job publication is unmeasured.
Queueing and unrelated setup do not enter the comparison. The exact runner
class, image, version, OS, and architecture match across each provider pair;
physical CPUs and runner regions were not measured.

Both warm arms report a hit for their exact series seed.
[cache-context.json](cache-context.json) retains the post-run GitHub inventory:
138 caches and 1,637,291,040 bytes across the repository, with both selected
cache keys present. This snapshot does not establish quota or historical eviction.

Reported BoringCache KV bytes and GitHub archive bytes describe selected caches.
They do not establish equivalent compression, physical or billable storage,
cross-tag deduplication, or complete workspace use. Cold Actions Cache storage
remains unmeasured because its save follows phase recording.

[evidence.md](evidence.md) links the independently downloaded and verified
archives. Rolling execution, other cases, and website publication remain
unqualified by this series.
