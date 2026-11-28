require File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/cache-overlay")

CacheOverlay.apply("upstream/web/Dockerfile") do |dockerfile|
  dockerfile.replace(/^RUN pnpm install --frozen-lockfile$/, "RUN --mount=type=cache,id=langfuse-pnpm,target=/pnpm/store,sharing=locked pnpm install --frozen-lockfile --store-dir=/pnpm/store")
  dockerfile.replace(/^RUN (NODE_OPTIONS=.*turbo run build --filter=web\.\.\.)$/, 'RUN --mount=type=cache,id=langfuse-next,target=/app/web/.next/cache,sharing=locked --mount=type=cache,id=langfuse-turbo,target=/app/.turbo/cache,sharing=locked \1')
  dockerfile.replace(/^RUN (\/usr\/local\/go\/bin\/go install )/, 'RUN --mount=type=cache,id=langfuse-go-mod,target=/go/pkg/mod,sharing=locked --mount=type=cache,id=langfuse-go-build,target=/root/.cache/go-build,sharing=locked \1')
  dockerfile.replace(/^RUN (cd \/src\/clickhouse-jwt-migrate &&)/, 'RUN --mount=type=cache,id=langfuse-go-mod,target=/go/pkg/mod,sharing=locked --mount=type=cache,id=langfuse-go-build,target=/root/.cache/go-build,sharing=locked \1')
end

CacheOverlay.apply("upstream/turbo.json") do |config|
  inputs = %w[NEXT_PUBLIC_* SENTRY_* NEXT_IGNORE_BUILD_ERRORS DOCKER_BUILD NEXT_MANUAL_SIG_HANDLE NEXT_TELEMETRY_DISABLED CI]
  config.replace(/^  "globalEnv": \[/, "  \"globalEnv\": [\n    #{inputs.map(&:inspect).join(",\n    ")},")
end
