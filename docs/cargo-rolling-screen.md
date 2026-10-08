# Zed rolling screen

Compare `boringcache-cargo-plus` with the pinned upstream `kache` Action on
fresh `ubuntu-24.04` runners. Run one seed and three successive first-parent
Zed commits. This is a single screening sample per commit, not a repeatable
performance claim. The lanes cache different layers: BoringCache uses sccache,
Cargo dependencies and target outputs; Kache uses its compiler store.

Use an isolated `series` and keep the lane and runner selection unchanged
throughout it. The workflow reads the cursor from committed `results/`, then
records the next run on the branch used for dispatch. A branch experiment does
not publish its implementation or records to `main`.

```sh
gh workflow run project.yml --repo boringcache/benchmarks \
  --ref cargo-rolling-screen \
  -f tool=cargo -f project=zed -f mode=rolling \
  -f lanes=boringcache-cargo-plus,kache -f runners=github \
  -f series=zed-kache-20261008
```

Wait for both lanes and cache publication to complete before the next dispatch.
Check each phase record's `sha`, `step`, `exit_status` and `output_ok`; a green
workflow alone does not prove the build succeeded. Stop the screen on a failed
build, failed output check, missing record or unsuccessful cache publication.
Do not retry a partially published seed as a cold observation.

The output check runs `zed --system-specs` and checks its embedded commit against
the checkout. It also requires a clean source tree. This checks the reported
build identity and executable startup, not every editor feature.

Retain the original phase JSON, BoringCache evidence, full job logs and job/step
timestamps. Report restore/build/save separately where the provider exposes
them. Unreported bytes or durations remain unmeasured. The phase `seconds`
field ends before the Kache Action's post step; report its post-step duration
alongside the phase time, and inspect the logs for upload completion. Do not
describe the phase time alone as the complete rolling cycle.

Kache stays at version `1.0.0`, Action
`ad7317540dcdd71c904f7a60a87b620a0c0e67ed`, with its existing inputs. Its GitHub
archive is immutable: an exact key hit skips saving. Record the actual restore
and save keys from each run, including whether the Action found a lockfile.
This screen measures that shipped Action behavior, not an accumulating S3
configuration. The earlier fresh run reported a `zed` executable hit despite
the Action's `cache-executables: false` input; use per-run native evidence to
identify actual reuse.

Compare the three changed-source cycles and their cache transfer costs before
choosing product work. A useful improvement must preserve the new commit's
output. Keep identical-source baselines separate. Repeat a promising result
before using it to justify an integration or a compiler-cache implementation.
