# Benchmark schedules

PR #42 is merged. Central activation remains off. Historical repositories still own the active
weekly, canary and source schedules. Central scheduled jobs require
`BENCHMARK_CADENCE_ACTIVE=true`; merging this branch does not activate them.
Manual qualification remains available. Historical triggers must be retired
before ownership changes, so the migration does not duplicate runs. The
[cutover procedure](cadence-cutover.md) includes the observed inventory and
prepared patches for 48 cron triggers in 17 repositories; none are applied yet.

`suites/scheduled.json` selects the maintained suite plus Moon, Pants, Buck2,
sbt and Nix: 24 source cases and 31 fresh targets. It excludes Docker corpus and
prospect drafts. Case definitions own workflow paths and variant inputs.

| Run | UTC schedule | CLI | Source |
| --- | --- | --- | --- |
| Weekly fresh | Monday 04:00 | Latest compatible published stable release | Declared pins |
| Nightly fresh | Daily 01:17 | Latest published canary | Declared pins |
| Rolling source check | Hourly, at :11 | Stable after activation; canary for pre-activation planning | Reviewed upstream candidates |

## Independent dispatch and ordered rolling caches

Fresh dispatch validates the whole suite and resolves one exact CLI tag before
starting a matrix of independent requests. Each target retains its own receipt.
The combined receipt preserves requested run IDs, failed or uncertain requests,
and missing targets. A dispatch succeeding does not establish that the builds
passed. Dry runs request no builds. Interrupted requests require receipt review
before retrying; an absent HTTP response does not prove GitHub rejected a run.

Source checks fan out by case, with six checks running at a time. Each case owns
its source-controller lock; one failed or slow case does not stop the others.
Rolling workflows serialize publication to the same cache with `queue: max`.
The next source cycle inspects the previous requested runs before advancing that
case again. An unchanged source does not request another build.

Source inspection runs with read-only repository permissions. A separate job
reconstructs only permitted source-pin changes, verifies the expected case and
shared harness, then conditionally publishes against the current branch head.
It records dispatch intent before making requests and retains receipts under
`migration/rolling/`, including an observation per candidate source. A concurrent
edit to the same case or shared harness blocks publication; an unrelated case's
commit can be retried against its new branch head. Publication uses GitHub's
[conditional commit API](https://docs.github.com/en/graphql/reference/commits#createcommitonbranch).

Deno retains adjacent-commit order. OBS retains its existing selection of the
next build-relevant change and its immediate parent, recording the previous
source separately. Zed selects dependency-verified candidates and promotes a
source only after its rolling build succeeds. Other cases retain their existing
promote-then-build order. Failed builds remain observations. Uncertain requests
block that case from automatic redispatch until their receipts are reviewed.

Before activation, the publication job only plans with a canary. It does not
change `main` or request rolling builds. Both the workflow and publisher require
active central ownership on `main` before publication.

## Workloads and reports

Every scheduled case now registers a rolling path, including the four native
cases, OBS, five REAPI cases and two Nix cases previously missing one. Definitions
and passing local checks do not establish live rolling qualification.

Native Docker runs load and inspect their output for both providers. REAPI
rolling runs retain the case/series cache; bazel-remote restores and publishes a
GitHub Actions cache and records the previous source and restored key. Nix and
OBS rolling runs permit both restore and publication. Missing seeds remain
bootstrap observations; they must not be described as proven cache reuse.

Nix workers import one common dependency store prepared outside the measured
build. The export excludes the measured package, checksums the archive and
checks the imported dependency hashes against the declared derivation. This
avoids independently rebuilding a nondeterministic dependency for each arm while
keeping strict package and dependency comparisons. The earlier Zed Nix screen
restored both providers' package outputs correctly but failed the dependency
baseline comparison; that failed run remains retained.

Run names use the case, optional variant, CLI channel and lane, followed by the
series or branch and sample. For example, `n8n / turbo | Canary fresh | main /
sample 1` and `n8n / turbo | Stable rolling | main / sample 1`. Stable tags are
not labelled as canaries merely because an exact CLI version was supplied.
Provider and phase remain visible in job labels. REAPI, Nix and OBS rolling
results use the canonical benchmark report and retain both
structured evidence and the comparison summary. Reports contain measurements
and verification results, without performance verdicts.

## Qualification and activation

The October 5 preflight rejected stable `v1.33.0`: it does not expose
`cache-registry --reapi-port`. Canary `vcli-canary-7a5b27146ebe` passed the full
31-target preflight. Weekly activation must wait for a compatible stable release;
it must not substitute a canary or silently omit the REAPI cases.

The complete controller rehearsal passed all 24 cases and planned changed-source
rolling requests with the canary without publishing or dispatching builds.
The earlier source matrix completed the cases independently and identified
recipe changes in Immich, Qdrant, msgpack and Zed. Their reviewed changes are
recorded in [the recipe review](recipe-reviews-2026-10-05.md). New source pins and
changed recipes still require live qualification.

The repository's Actions cache limit is 200 GB, with seven-day retention.
Capacity alone does not establish that a particular rolling seed was retained
or restored.

Remaining activation requirements:

- Pass hosted checks for the complete controller and rolling changes.
- Qualify the new and changed rolling paths with actual source advancement,
  retained seeds, verified outputs and canary CLI execution.
- Pass the corrected Zed Nix cold/warm screen using the common dependency seed.
- Verify main-branch workflow-token publication at cutover. The
  [isolated publication rehearsal](../migration/rehearsals/mastodon-publication/review.md)
  passed conditional commits, dispatch and reconciliation with the operator's
  GitHub CLI; the hosted rehearsal passed inspection and dry-run publication.
- Retire replaced historical cron triggers while preserving manual and release
  entrypoints; verify no outstanding duplicate dispatches.
- After a compatible stable release, change monitoring and publication ownership
  and set `BENCHMARK_CADENCE_ACTIVE=true`.
