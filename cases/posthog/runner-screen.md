# PostHog runner screen

The manual `project-fresh.yml` route runs one PostHog group containing ordinary
Depot and Namespace four- and eight-core runners. The reviewed
[selections](runner-screen-selections.json) use `native-fresh-benchmark.yml` with
`variant: layers` and `provider: boringcache`. The route reuses shared provider
setup, source preparation, cache identity, timing, verification, reporting and
product-evidence retention.
Each runner selection performs one cold seed and one identical-source replay on
separate fresh workers. Distinct benchmark suffixes separate each selection's
cache identity and artifacts within the group. The seed uses a new run/attempt cache identity and publishes it.
The replay restores that exact seed without publication. The shared `layers`
recipe builds and loads the image and verifies its presence. GitHub OIDC provides
BoringCache authentication. This route does not use `DEPOT_TOKEN` or a provider's
remote Docker builder.

| Runner selection | Label | CPU | Memory | Provider Docker caching |
| --- | --- | ---: | ---: | --- |
| Depot, four cores | `depot-ubuntu-24.04-4` | 4 | 16 GB | No Depot remote builder or Actions Cache arm |
| Depot, eight cores | `depot-ubuntu-24.04-8` | 8 | Recorded per worker | No Depot remote builder or Actions Cache arm |
| Namespace, four cores | `namespace-profile-buildkit-4c` | 4 | 16 GB | Docker “No caching”; cache volumes disabled |
| Namespace, eight cores | `namespace-profile-buildkit-8c` | 8 | 16 GB | Docker “No caching”; cache volumes disabled |

The Namespace profiles use Ubuntu 24.04 on amd64. The current trial does not offer
8 cores with 32 GB; do not present that arm as memory-matched to Depot's eight-core
runner. Provider-side Docker caching is disabled while BoringCache still owns its
remote layer cache. The profiles and workflow measure that distinction.

The timer covers provider setup and the Docker build, including cache work,
image export and load. Output inspection runs after timing. Selected-tag storage
is measured from product evidence when available; missing storage stays
unmeasured. Base-image pulls and upstream package downloads remain part of the
build. A new logical identity does not establish an empty physical provider store
or empty external package-service caches.

Runner resource and Docker endpoint evidence is retained for each phase. The
phase record includes the requested runner class. Review those artifacts and
final product evidence before attributing timing to a CPU count or claiming reuse.

```sh
gh workflow run project-fresh.yml --repo boringcache/benchmarks --ref main \
  -f case_id=posthog -f cli_version=vcli-canary-252077d7b8fb \
  -f selections="$(cat cases/posthog/runner-screen-selections.json)"
```

The group fixes an exact `cli_version`. An optional `buildkit_image` in each
selection selects a managed BuildKit image; empty inputs use the shared default. All machine arms
must retain matching source, recipe, output, architecture, CLI and BuildKit image.
The first grouped dispatch is a bounded one-sample diagnostic, without a comparative
performance claim. A published runner comparison requires a frozen series and
its declared sample count.

Native remote-cache comparator work is separate. See the
[Depot cache screening inventory](../../docs/depot-cache-screening.md).

PostHog skips disk cleanup when at least 40 GiB is free. The CLI's
`BORINGCACHE_EPHEMERAL_PRIVILEGED_RUNNER=1` opt-in applies only to manual
main-branch dispatches or identity-verified frozen cadence tags on these four reviewed disposable runner labels. Other
self-hosted runner labels retain the CLI's default refusal to start managed
BuildKit. [Depot documents its single-tenant, disposable runner lifecycle](https://depot.dev/docs/github-actions/overview).

## Scheduled and rolling runs

The scheduled suite includes these four selections alongside PostHog's existing
`layers` and `combined` comparisons. Nightly, weekly and upstream rolling
requests keep them in one PostHog project group. Rolling selections retain the
same runner suffix and declared cache scope across source commits; each new
runner scope needs its own seed before a changed-source observation.

Set the repository variable `BENCHMARK_ACTIVE_CASES` to `["posthog"]` to activate
PostHog while the rest of the suite remains paused. `BENCHMARK_CADENCE_ACTIVE=true`
continues to activate the entire suite. Upstream inspection continues for every
scheduled project regardless of either activation setting. Manual nightly and
weekly dispatches accept `case_id=posthog` to select this project.

Frozen fresh batches also accept the reviewed runner labels from immutable
`benchmark-<run-id>` tags. The declared harness SHA must match the tag's commit,
and preparation checks the exact case definition before running upstream code.
