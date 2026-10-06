# Depot remote-cache screening

The first route is the [PostHog runner screen](../cases/posthog/runner-screen.md)
through BoringCache's managed BuildKit backend on ordinary Depot and Namespace
four- and eight-core runners.
Native Depot remote-cache comparisons need separate definitions and bounded
qualification before joining the scheduled suite.

## Existing workload coverage

Depot's [supported cache integrations](https://depot.dev/docs/cache/overview)
overlap these existing cases:

| Native cache protocol | Existing case or variant | Comparator work |
| --- | --- | --- |
| Bazel remote cache | `grpc` | Add Depot alongside the existing provider arms |
| Go build cache | `hugo-go` | Select Depot's native cache instead of an archived local cache |
| Gradle HTTP build cache | `opentelemetry-java` | Use Depot's endpoint for the same task outputs |
| Maven build cache | `spring-ai` | Verify the upstream extension and Depot configuration together |
| Turborepo remote cache | `n8n` / `turbo`, PostHog tool-cache projection | Retain native task hits and outputs; container builds need secret mounts |
| Nx remote cache | `storybook` / `nx` | Select Depot's native endpoint for the existing Nx tasks |
| sccache | `deno`, `zed`, selected Docker compiler-cache evaluations | Retain compiler statistics; distinguish Cargo target-directory reuse from sccache reuse |
| Moon remote cache | `gogs-moon`, `opencut-moon` | Use the reviewed remote execution cache configuration |
| Pants remote cache | `stackstorm-pants` | Use the reviewed remote execution cache configuration |
| Xcode compilation cache | `obs-studio` / `xcode` | Verify supported macOS runner, compiler and native cache configuration first |

Buck2 and sbt also have REAPI cases here. Depot's published integration list does
not establish that those exact clients and configurations are qualified.

On Depot runners, actions using the GitHub Actions cache API automatically use
[Depot Cache](https://depot.dev/docs/cache/integrations/github-actions). That
archive/layer-cache path must be identified as Depot-backed, and kept distinct
from each tool's native remote-cache API. GitHub's cache-list API does not measure
Depot storage. Unavailable Depot storage stays unmeasured.

## Seed and rolling contract

For each qualified tool, begin with one Depot seed build and one reviewed
changed-source build on a separate fresh worker. Freeze the exact seed and
destination SHAs, recipe, outputs, toolchain, architecture, runner class, backend,
cache scope and timed operation before dispatch. Reuse the same declared cache
scope for that pair and retain both observations, including failures. Native hits
and output checks must confirm reuse. An identical-source replay may be added as
a separate observation; it cannot substitute for changed-source rolling evidence.

Before calling a seed cold, verify how that native Depot integration isolates a
new cache identity. Depot's repository scoping for its Actions API does not prove
that every native protocol has a fresh namespace. Do not clear shared caches to
manufacture a cold observation. Existing provider storage and inherited runner
configuration must be recorded when isolation cannot be established.

Use the job-scoped Depot credentials where the integration supports them. Keep
`DEPOT_TOKEN` in GitHub Secrets for integrations that need it, and pass container
credentials as BuildKit secrets. Do not print tokens or put them in build args.
BoringCache and uncached arms must use their declared configuration even when
Depot runners provide automatic native cache environment settings.

All provider arms must build the same reviewed outputs on the same runner class.
A Depot remote container builder is a separate compute arm: record its actual
CPU, memory and architecture rather than assigning the runner's core count to it.
Timing includes the declared provider setup, build and cache work. Queueing,
unrelated setup, image verification and complete job duration remain context.

This document records the next qualification work. It does not enable schedules,
declare native clients qualified, or assert that the smaller runner is faster.
