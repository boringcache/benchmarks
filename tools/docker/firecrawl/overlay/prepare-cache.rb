require File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/cache-overlay")

CacheOverlay.apply("upstream/apps/api/Dockerfile") do |dockerfile|
  dockerfile.replace(/^RUN (cd sharedLibs\/go-html-to-md &&)/, 'RUN --mount=type=cache,id=firecrawl-go-mod,target=/go/pkg/mod,sharing=locked --mount=type=cache,id=firecrawl-go-build,target=/root/.cache/go-build,sharing=locked \1')
  dockerfile.replace(/^    (go build -o libhtml-to-markdown\.so )/, '    env -u CC -u CXX \1')
  install = File.read(File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/install-sccache.Dockerfile"))
  dockerfile.replace(/^COPY pnpm-lock\.yaml pnpm-workspace\.yaml package\.json \.\/$/, "#{install}\n\\0")
  dockerfile.replace(/^    pnpm install --frozen-lockfile$/, "    --mount=type=cache,id=firecrawl-sccache,target=/root/.cache/sccache,sharing=locked \\\n    RUSTC_WRAPPER=sccache pnpm install --frozen-lockfile && sccache --show-stats")
end
