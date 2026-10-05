# Independent fresh samples

Both declared samples passed. Their cold jobs started at 09:10:07 and 09:10:09
UTC on October 5, before either sample finished. Their warm jobs also overlapped.
Each sample used its own scope, both providers restored their matching cold seed,
and all eight builds verified Hugo output. BoringCache warm jobs were restore-only.
Both report jobs and final product-evidence uploads passed.

The [generated report](report.md) retains all eight observations. BoringCache was
slower in these two samples: median build-and-reuse time was 87.5 versus 70 seconds
cold, and 21 versus 9 seconds warm. Actions Cache cold storage was unmeasured;
the warm records measured each restored key. These two samples do not establish
a general performance result.

This is harness qualification, not a speed claim. Record queue and job duration
as context and use the declared build-and-reuse metric for measurements. Shared
GitHub cache capacity can still affect seed availability.

During this qualification, a repository snapshot reported 241 cache entries,
10,607,436,133 bytes and a 10 GB setting. This is context, not per-phase occupancy
or proof that no eviction occurred. Both warm Actions Cache keys were present.

The two [evidence archives](https://github.com/boringcache/benchmarks/releases/tag/evidence-independent-samples-2026-10-05)
were downloaded again and checked against their SHA-256 digests. All 34 listed
files and both scoped run inventories verified. The records establish independent
sample execution, not readiness to delete an old repository.
