# Hugo loaded-image comparison

The [first image-output screening run](https://github.com/boringcache/benchmarks/actions/runs/37104595025)
failed in both providers with `docker exporter does not currently support exporting manifest lists`.
The recipe requested provenance and SBOM attestations while loading the image
into the runner's Docker image store. The failed request and its logs remain
evidence; it supplies no verified timing observations.

The fresh loaded-image comparison disables provenance and SBOM attestations in
both providers. This is an explicit output projection from the upstream
publication recipe. The source, Dockerfile, build arguments, and image load are
unchanged. Publication paths retain their committed attestations.

The plan activation regression checks the exact arguments for loaded and
unloaded output. The Actions recipe uses the same `load_image` condition. The
shared verifier inspects the selected local image after timing capture; this
establishes materialization, not runtime behavior. Corrected execution uses a
new predeclared series.
