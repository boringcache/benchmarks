# Registry transfer experiment

`registry.yml` measures a push and a pull of the same published PostHog Linux
amd64 image. `registry/posthog.json` pins the source manifest, image config,
source commit and compressed layer bytes. Each operation runs on GitHub 4c.
Source download, authentication, image tagging and output verification are
outside the timer. Each pull runs on a separate runner with no local images.
The image config must match the pinned source after publication and after pull.
An unsuccessful command or output check fails the job and retains its record.

BoringCache pushes use `boringcache docker push`; all pulls and the other
providers' pushes use Docker. These are image-transfer measurements, separate
from the rolling BuildKit cache comparisons. New repository names separate
GHCR, Depot and BoringCache runs; provider-wide blob reuse may still occur.
ECR uses a dedicated experiment repository with a run-specific tag. These
measurements do not assert that provider storage was empty before a push.

Dispatch with `gh workflow run registry.yml -f provider=all`, or select
`boringcache`, `ghcr`, `ecr` or `depot`. Do not retry a run: dispatch a new one.
Each job uploads its JSON record as `registry-<provider>-<operation>` for 14 days.
Failed authentication or source preparation produces no timed record.

The BoringCache push uses the repository's OIDC trust and the CLI version in
`versions.toml`. `BORINGCACHE_REGISTRY_TOKEN` authenticates Docker's manifest
verification and pull. It is no longer used by a build-cache lane. Depot uses
`DEPOT_TOKEN` and the `Benchmarks` organization's standard registry. GHCR uses
the workflow token. Secrets are passed only to their provider's jobs.

ECR is in `us-east-1`, under `boringcache-benchmark-storage`. The matching local
AWS profile assumes that role. Repository variables
`REGISTRY_BENCHMARK_AWS_ROLE` and `REGISTRY_BENCHMARK_ECR_REPOSITORY` configure
GitHub OIDC access, restricted to this repository's `main` branch. Role trust
and local role-assumption access expire on 2026-10-16 at 00:00 UTC. ECR's
lifecycle policy expires images after one day; AWS may process expiration later.
The role, empty repository, local profile and bootstrap assumption policy remain
until removed. Remove the experiment's tags/digests from GHCR, Depot and
BoringCache after downloading the results; artifact expiry does not remove images.

Provider setup references:

- [BoringCache image publication](https://boringcache.com/docs/adapters)
- [GHCR authentication and image transfers](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [ECR image publication](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)
- [Depot Registry](https://depot.dev/docs/registry/quickstart)
