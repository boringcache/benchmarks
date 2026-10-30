# Registry transfer experiment

`registry.yml` measures a push and a pull of the same PostHog Linux amd64 image
for each provider. Each operation runs on GitHub 4c. Source export, download,
loading, authentication, image tagging and output verification are outside the
timer. Each pull runs on a separate runner with no local images.
The image config must match the pinned source after publication and after pull.
An unsuccessful command or output check fails the job and retains its record.

BoringCache pushes use `boringcache docker push`; all pulls and the other
providers' pushes use Docker. These are image-transfer measurements, separate
from the rolling BuildKit cache comparisons. New repository names separate
GHCR, Depot and BoringCache runs; provider-wide blob reuse may still occur.
ECR uses a dedicated experiment repository with a run-specific tag. These
measurements do not assert that provider storage was empty before a push.

After a PostHog benchmark run publishes its results, it dispatches one registry
comparison using the image built by `boringcache-docker` on `github`. Rolling
runs export their rolling image; fresh runs export their warm image. The build
and output check must pass. Runs without that lane, preflights, skipped builds
and job retries do not dispatch a comparison. Other lanes may fail without
preventing a comparison of the successful source image.

The source image archive is retained for two days. Its metadata records the
PostHog commit, build run, image config digest, image size, archive size and
archive checksum. Every provider loads that same archive before timing its
push. Pull jobs download only the metadata and verify the image config after
pulling. The comparison accepts source artifacts only from this repository's
`project.yml` runs on `main`. Registry records include `source_run_id` so they
can be joined to the build measurements.

To compare a retained build manually, dispatch with
`gh workflow run registry.yml -f provider=all -f source_run=<PostHog-run-id>`.
Without `source_run`, the workflow uses the published image pinned by manifest,
image config, source commit and compressed layer bytes in `registry/posthog.json`.

Dispatch with `gh workflow run registry.yml -f provider=all`, or select
`boringcache`, `ghcr`, `ecr` or `depot`. Do not retry a run: dispatch a new one.
Each job uploads its JSON record as `registry-<provider>-<operation>` for 14 days.
Failed authentication or source preparation produces no timed record.

The BoringCache push and pull use the repository's OIDC trust and the CLI version
in `versions.toml`. `boringcache docker login` registers the Docker credential
helper, and `boringcache ci run` supplies short-lived Registry credentials for
publication, Docker's manifest verification and pull. No static BoringCache token
is required. Depot uses
`DEPOT_TOKEN` and the `Benchmarks` organization's standard registry. GHCR uses
the workflow token. Secrets are passed only to their provider's jobs.

ECR runs in `us-east-1`. Repository variables `REGISTRY_BENCHMARK_AWS_ROLE`
and `REGISTRY_BENCHMARK_ECR_REPOSITORY` configure access. Its lifecycle policy
expires images after one day; AWS may process expiration later.

Provider setup references:

- [BoringCache image publication](https://boringcache.com/docs/adapters)
- [GHCR authentication and image transfers](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [ECR image publication](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)
- [Depot Registry](https://depot.dev/docs/registry/quickstart)
