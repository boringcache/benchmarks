require File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/cache-overlay")

CacheOverlay.apply("upstream/Dockerfile") do |dockerfile|
  opam = "RUN --mount=type=cache,id=semgrep-opam-downloads,target=/root/.opam/download-cache,sharing=locked"
  dockerfile.replace(/^RUN make switch$/, "#{opam} make switch")
  dockerfile.replace(/^RUN make install-deps$/, "#{opam} make install-deps")
  dockerfile.replace(/^RUN opam exec -- make core$/, "RUN --mount=type=cache,id=semgrep-dune,target=/var/cache/dune,sharing=locked DUNE_CACHE=enabled-except-user-rules DUNE_CACHE_ROOT=/var/cache/dune DUNE_CACHE_STORAGE_MODE=copy opam exec -- make core")
  dockerfile.replace(/^RUN (apk add --no-cache --virtual=\.build-deps build-base make py3-pip && \\\n)     pip install \/pysemgrep/, 'RUN --mount=type=cache,id=semgrep-pip,target=/root/.cache/pip,sharing=locked \1     env -u PIP_NO_CACHE_DIR pip install /pysemgrep')
end
