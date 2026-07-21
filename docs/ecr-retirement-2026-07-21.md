# ECR Benchmark Control Retirement

Date: 2026-07-21

## Decision

Private regional ECR is retired from all active benchmark runs. It
was an independent BuildKit `type=registry` cache control, not the destination
for deployable benchmark images. Keeping it active accumulated cache storage and
transfer cost after the comparison had already answered the product question.

Owned workflow and composite-action YAML contains no ECR job, input, AWS OIDC
setup, or registry-cache implementation. A future private-registry comparison
must be provisioned as a bounded experiment with its own cleanup rather than
reviving this recurring lane.

## Preserved performance evidence

The table is an archive of existing artifacts; this retirement did not trigger
new ECR runs. Values are arithmetic means over the latest three healthy rolling
samples selected on 2026-07-21 by `scripts/publish-index.rb`:

- **Scenario** is the benchmark's measured rolling scenario duration.
- **Tool elapsed** is scenario time plus cache export and any recorded
  post-cleanup time. It is the provider-comparison headline.
- **Import** and **export** are BuildKit cache operations reported by the
  benchmark artifact.
- **Stored** is ECR's reported compressed cache-manifest size, not an AWS bill.

| Scenario | n | Scenario | Tool elapsed | Import | Export | Stored | Raw runs |
|---|---:|---:|---:|---:|---:|---:|---|
| Hugo | 3 | 73.7s | 77.5s | 0.7s | 3.8s | 0.34 GiB | [29716349889](https://github.com/boringcache/benchmark-hugo/actions/runs/29716349889), `29240125044`, `29223295753` |
| Immich | 3 | 219.0s | 322.5s | 0.5s | 103.5s | 2.88 GiB | [29844467738](https://github.com/boringcache/benchmark-immich/actions/runs/29844467738), `29840235010`, `29835289611` |
| Mastodon | 3 | 133.7s | 170.6s | 0.9s | 36.9s | 1.03 GiB | [29844771395](https://github.com/boringcache/benchmark-mastodon/actions/runs/29844771395), `29835532384`, `29817877222` |
| Mastodon Streaming | 3 | 18.3s | 18.8s | 0.6s | 0.5s | 0.10 GiB | [29844772254](https://github.com/boringcache/benchmark-mastodon/actions/runs/29844772254), `29835533448`, `29817880029` |
| Discourse Docker | 3 | 206.0s | 250.2s | 0.9s | 44.2s | 1.03 GiB | [29857843705](https://github.com/boringcache/benchmark-discourse/actions/runs/29857843705), `29853103741`, `29846604467` |
| Discourse Base Deps | 3 | 15.7s | 17.0s | 0.7s | 1.4s | 0.70 GiB | [29857851547](https://github.com/boringcache/benchmark-discourse/actions/runs/29857851547), `29853101963`, `29846602123` |
| Discourse Web-Only | 3 | 14.0s | 15.2s | 0.6s | 1.2s | 1.40 GiB | [29857851547](https://github.com/boringcache/benchmark-discourse/actions/runs/29857851547), `29853101963`, `29846602123` |
| Discourse Base Release | 3 | 14.7s | 16.2s | 0.7s | 1.5s | 1.50 GiB | [29857851547](https://github.com/boringcache/benchmark-discourse/actions/runs/29857851547), `29853101963`, `29846602123` |
| Discourse Test Release | 3 | 17.7s | 19.4s | 0.8s | 1.8s | 1.95 GiB | [29857851547](https://github.com/boringcache/benchmark-discourse/actions/runs/29857851547), `29853101963`, `29846602123` |
| PostHog | 3 | 1187.0s | 1612.5s | 0.7s | 425.5s | 7.14 GiB | [29859494860](https://github.com/boringcache/benchmark-posthog/actions/runs/29859494860), `29857487121`, `29853289104` |
| n8n | 3 | 282.3s | 383.5s | 0.8s | 101.2s | 0.77 GiB | [29859464651](https://github.com/boringcache/benchmark-n8n/actions/runs/29859464651), `29857454069`, `29844629886` |
| n8n Runners | 3 | 62.3s | 83.2s | 0.8s | 20.8s | 0.28 GiB | [29859464651](https://github.com/boringcache/benchmark-n8n/actions/runs/29859464651), `29857454069`, `29844629886` |
| n8n Runners Distroless | 3 | 108.0s | 147.1s | 0.8s | 39.1s | 0.47 GiB | [29859464651](https://github.com/boringcache/benchmark-n8n/actions/runs/29859464651), `29857454069`, `29844629886` |

All 13 named Docker scenarios had three healthy selected ECR samples. The
on-demand `docker-cache-proofs` workflow exposes many selectable fixtures rather
than one durable benchmark lane. Its old ECR runs remain historical evidence,
but the runnable ECR path is removed; retirement does not spend money rerunning
every fixture to manufacture a complete matrix.

The generated `data/latest/providers.json` feed continues to recognize
`ecr-cache` as **ECR (retired control)**. That keeps raw historical artifacts
queryable alongside BoringCache and GHA while they remain in GitHub's retention
window. This document is the durable retirement snapshot after those artifacts
expire.

## Cost and cleanup boundary

The stored column totals per-scenario manifest sizes and must not be summed into
an AWS invoice: rolling scopes can share or supersede underlying objects, and
request/transfer charges are separate. Capture the AWS Cost Explorer billing
window and current ECR repository inventory before deletion, then verify the
post-retirement window reaches the expected baseline.

### Live AWS baseline

The read-only inventory was captured in `us-east-1` on 2026-07-21:

| Repository | Image/cache records | Summed reported image size | Latest push |
|---|---:|---:|---|
| `boringcache/docker-cache-proofs-cache` | 15 | 53.42 GiB | 2026-07-20 21:22 BST |
| `boringcache/benchmark-hugo-cache` | 1 | 0.34 GiB | 2026-07-17 13:00 BST |
| `boringcache/benchmark-posthog-cache` | 32 | 228.03 GiB | 2026-07-21 20:17 BST |
| `boringcache/benchmark-docker-cache` | 0 | 0 GiB | none |
| `boringcache/benchmark-discourse-cache` | 24 | 27.12 GiB | 2026-07-21 19:39 BST |
| `boringcache/benchmark-immich-cache` | 14 | 37.85 GiB | 2026-07-21 16:33 BST |
| `boringcache/benchmark-mastodon-cache` | 7 | 6.30 GiB | 2026-07-21 16:39 BST |
| `boringcache/benchmark-n8n-cache` | 67 | 33.15 GiB | 2026-07-21 20:07 BST |
| **Total** | **160** | **386.20 GiB** | |

These are summed `describe-images` sizes, not deduplicated billed bytes. They
are useful for target verification and explaining repository growth, but AWS
Cost Explorer remains the billing source of truth.

For 2026-07-01 through 2026-07-21, Cost Explorer reported an estimated:

- **$127.43** for 1,415.88 GB of `DataTransfer-Out-Bytes`;
- **$51.56** for 515.64 GB-month of `TimedStorage-ByteHrs`; and
- **$178.99 total ECR cost** month to date.

Once the workflow changes land, recurring benchmark ECR transfer should stop.
Storage cost will not disappear merely because writes stop; it should approach
zero only after the retained objects are explicitly removed. Keep both
expectations separate in the post-retirement verification.

The user-authorized cleanup is deliberately narrower than the historical
retirement record: after the runtime removal is verified on every owning main
branch, delete the live objects and eight exact repositories above in AWS
account `416997488804` / `us-east-1`. Do not delete GitHub workflow runs,
artifacts, provider-index compatibility, or this evidence snapshot. Remove
GitHub variables and IAM/OIDC access only when live reference checks prove they
are exclusive to these retired lanes.
