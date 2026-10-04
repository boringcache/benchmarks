# Chroma fresh comparison

The native fresh comparison uses the pinned source and the committed Docker
wrapper for both providers. It builds the CLI target for Linux AMD64. Both arms
export and load the image during the measured build, then inspect that image.
The BoringCache plan retains its declared compiler-cache proof checks.

Cold and warm phases use the shared source preparer, which restores the exact
gitlink and removes untracked files in the disposable source checkout. Warm is
an identical-source replay. The older case-specific preparer created
`rust/.boringcache-warm-source-change` to invalidate a Docker source layer and
exercise tool-cache reuse. That diagnostic marker is excluded from the new
native comparison. The original script remains as historical recipe material;
it is not called by this action.

This projection changes both the output export and the warm-source preparation.
It requires a new predeclared series. Older timings cannot be combined with the
new series. Image inspection establishes a produced image; it does not test the
application's runtime behavior. Live output and completion qualification remain
required before publication or caller cutover.
