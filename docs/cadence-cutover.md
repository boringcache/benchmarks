# Cadence cutover

`boringcache/benchmarks` owns the selected benchmark execution and monitoring.
The retired execution repositories are archived. On October 6, the user approved
central scheduling with the latest published canary until a compatible stable
release is available. The earlier stable-release gate is superseded.

The current suite selects 24 source cases, 32 case/variant selections and 34
underlying fresh workers, grouped into 22 project runs. Fresh, Nightly and Rolling
retain separate cadence identities. The Docker corpus is excluded from scheduling.
See [cadence.md](cadence.md) for schedules, evidence and storage scope.

Activation verification:

1. Verify the exact published selector in `config/cli.json`, its release checksums
   and the required native CLI commands. Run the full suite preflight on the
   committed harness and require hosted guardrails to pass.
2. Confirm retired execution repositories are archived and retain their run URLs
   and exported evidence. Archiving prevents their historical schedules from
   requesting new work.
3. Set `BENCHMARK_CADENCE_ACTIVE=true` in `boringcache/benchmarks`. This enables
   automatic Fresh/Nightly dispatch and reviewed upstream source publication.
4. Inspect the first Fresh and Nightly receipts, immutable harness refs and
   project runs. Check each receipt against the full suite and inspect the source
   cycle's proposals and rolling requests. A requested build is not completed.
5. Verify the central monitor retains all three cadence outcomes and the publisher
   commits current observations. Failed, cancelled, pending and unmeasured states
   remain explicit.

The [October 5 inventory](../migration/cadence-schedule-inventory-2026-10-05.json)
and [prepared patches](../migration/cadence-cutover-patches) retain the historical
48-schedule retirement review. Archiving the execution repositories supersedes
applying those patches. Historical qualification documents describe their original
review date and do not set the current activation policy.

To stop automatic central dispatch, unset the activation variable and inspect
already requested runs. Keep their receipts and observations. Restore retired
schedules only after reviewing repository ownership and draining central requests.
