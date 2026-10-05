# NativeLink R2 cache comparator

The `nativelink` provider runs NativeLink 1.7.4 on the benchmark worker and stores
CAS and action-cache objects in Cloudflare R2's `benchmarks` bucket. Bazel builds
locally. The server exposes only cache services on `127.0.0.1:50051`; it has no
scheduler, execution service, or remote workers.

This topology differs from BuildBuddy's hosted cache. The timed setup includes
downloading the pinned, checksum-verified release, starting the NativeLink server,
and checking its R2 seed. Build timing includes Bazel's
remote uploads and downloads. Output verification, seed metadata publication,
and storage listing follow build timing.

Each fresh sample has its own R2 prefix, derived from the shared case/series/run/
attempt scope. A cold run rejects an occupied prefix. Warm runs use a new worker
and empty local NativeLink stores, disable Bazel cache uploads, require a matching
R2 seed and remote cache hits, and compare both binary SHA-256 hashes with the
cold seed. Rolling runs retain the shared rolling prefix and record the previous
seed's source and run identity before publishing the next verified seed.

The local CAS tier is bounded to 2 GB of disk and the action-cache tier to 100 MB
of memory. R2 holds the persistent slow tiers, with separate `cas/` and `ac/`
prefixes. Storage is the sum of R2 object sizes under those two prefixes after
the build; seed metadata is excluded. It is not a statement about billed storage
or equivalence to another provider's compression or deduplication.

Repository Actions secrets `NATIVELINK_R2_ACCESS_KEY_ID` and
`NATIVELINK_R2_SECRET_ACCESS_KEY` provide object read/write access to this bucket.
Only NativeLink startup and storage/verification steps receive them. The config
artifact contains environment-variable placeholders. Evidence retains the
release digest, server and Bazel logs, seed lineage, output hashes, and R2 object
listing. Failed attempts retain diagnostics too.

The hourly source dispatcher and fresh suite fan-out use the existing gRPC
workflows, so this fourth provider does not add a duplicate schedule. Shared
cadence activation remains subject to the documented CLI release gate.
