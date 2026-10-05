# Independent fresh samples

Two samples test the shared workflow after removing its repository-wide queue.
Dispatch both before either finishes. Each sample must retain its own cold seed,
complete both providers' cold/warm builds, verify Hugo output, and retain final
product evidence. Compare run/job timestamps to establish overlapping execution.

This is harness qualification, not a speed claim. Record queue and job duration
as context and use the declared build-and-reuse metric for measurements. Shared
GitHub cache capacity can still affect seed availability.
