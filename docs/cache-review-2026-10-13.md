# Benchmark cache review, 2026-10-13

Read the [cache entries](https://boringcache.com/boringcache/benchmarks/cache/entries), [usage](https://boringcache.com/boringcache/benchmarks/cache/usage), and [retention settings](https://boringcache.com/boringcache/benchmarks/cache/settings), the CLI inventory, and the production cache MCP between 10:47 and 10:56 UTC. Sizes below use decimal GB. Live runs can change these totals during collection.

## Tags

The page listed 206 targets: 145 snapshot tags and 61 tool-cache tags. Names were unique within both inventories. Each snapshot tag pointed to a different current entry. Current rolling names use fixed project, lane, runner, and series scopes, with platform suffixes where required. They do not include the step number or workflow run ID.

| Scope | Snapshot tags | Tool-cache tags | Listed size before shared-data deduplication |
| --- | ---: | ---: | ---: |
| Current rolling configuration | 120 | 33 | — |
| Fresh runs | 15 | 16 | About 33.5 GB |
| Retired runners, cases, or series | 10 | 12 | About 42.5 GB |

The 53 fresh or retired targets total about 76.0 GB in listed sizes. This is not an estimate of reclaimable physical storage: tags and versions can share blobs. Retired scopes include PostHog Depot 4 and Namespace runners, Zed Namespace, the first Deno/sbt/OBS series, buck2-prelude, and a dated Zed experiment. Their last activity was four to five days ago. Fresh scopes were last used within the past four days.

Retention is configured for seven idle days and five versions per tag, with no protection rules. These older targets are still inside that idle window. Tool-cache retention also keeps keys used by recent publications. The repository's two-hour BuildKit cleanup manages GitHub Actions caches; BoringCache retention runs on the service.

## Storage and growth

The CLI status snapshot at 10:48 UTC reported:

| Metric | Value |
| --- | ---: |
| Current targets, logical size | 382.6 GB |
| Current targets, unique data | 287.1 GB |
| Shared-data savings for current targets | 95.6 GB, 25% |
| Ready-to-restore storage, including retained data | 575.6 GB |
| Ready-to-restore snapshot entries | 628 |
| Published version records | 518 |
The largest active growth is in PostHog's Turbo cache mounts:

| Runner | Current mount | Retained snapshots | Sum of snapshot sizes |
| --- | ---: | ---: | ---: |
| GitHub x86 | 18.29 GB | 5 | 89.68 GB |
| GitHub ARM | 18.52 GB | 5 | 90.84 GB |
| Depot 8 | 19.02 GB | 5 | 92.85 GB |

These three current mounts total 55.83 GB. Each grew by about 0.76 GB across its five retained snapshots that morning; successive content-changing snapshots added roughly 0.25 GB. Stable tag names and bounded version counts do not bound the contents of a growing build cache. The 273.37 GB sum across their versions counts shared data repeatedly and is not physical usage.

No cache targets, retention settings, or storage resources were changed during this review. Recheck expiry after the seven-day window and review growth inside the PostHog mounts before changing benchmark cache behavior.
