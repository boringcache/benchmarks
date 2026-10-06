# PostHog runner screen

The manual `native-fresh-benchmark.yml` route runs the pinned PostHog Docker recipe
through BoringCache's managed BuildKit backend on ordinary Depot or Namespace
runners. Select `case_id: posthog`, `variant: layers`, `provider: boringcache` and
one of the runner labels below. The route reuses shared provider setup, source
preparation, cache identity, timing, verification, reporting and product-evidence
retention.

Each dispatch performs one cold seed and one identical-source replay on separate
fresh workers. The seed uses a new run/attempt cache identity and publishes it.
The replay restores that exact seed without publication. The shared `layers`
recipe builds and loads the image and verifies its presence. GitHub OIDC provides
BoringCache authentication. This route does not use `DEPOT_TOKEN` or a provider's
remote Docker builder.

| Runner selection | Label | CPU | Memory | Provider Docker caching |
| --- | --- | ---: | ---: | --- |
| Depot, four cores | `depot-ubuntu-24.04-4` | 4 | 16 GB | No Depot remote builder or Actions Cache arm |
| Depot, eight cores | `depot-ubuntu-24.04-8` | 8 | 32 GB | No Depot remote builder or Actions Cache arm |
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
gh workflow run native-fresh-benchmark.yml --repo boringcache/benchmarks --ref main -f case_id=posthog -f variant=layers -f provider=boringcache -f runner_label=depot-ubuntu-24.04-4
gh workflow run native-fresh-benchmark.yml --repo boringcache/benchmarks --ref main -f case_id=posthog -f variant=layers -f provider=boringcache -f runner_label=depot-ubuntu-24.04-8
gh workflow run native-fresh-benchmark.yml --repo boringcache/benchmarks --ref main -f case_id=posthog -f variant=layers -f provider=boringcache -f runner_label=namespace-profile-buildkit-4c
gh workflow run native-fresh-benchmark.yml --repo boringcache/benchmarks --ref main -f case_id=posthog -f variant=layers -f provider=boringcache -f runner_label=namespace-profile-buildkit-8c
```

The optional `cli_version` and `buildkit_image` inputs select an exact CLI release
or managed BuildKit image. Empty inputs use the shared defaults. All machine arms
must retain matching source, recipe, output, architecture, CLI and BuildKit image.
The first dispatches are bounded one-sample diagnostics, without a comparative
performance claim. A published runner comparison requires a frozen series and
its declared sample count.

Native remote-cache comparator work is separate. See the
[Depot cache screening inventory](../../docs/depot-cache-screening.md).
