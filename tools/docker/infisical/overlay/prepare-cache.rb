require File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/cache-overlay")

CacheOverlay.apply("upstream/Dockerfile.standalone-infisical") do |dockerfile|
  npm = "RUN --mount=type=cache,id=infisical-npm,target=/root/.npm,sharing=locked"
  %w[--ignore-scripts --omit=dev].each do |argument|
    dockerfile.replace(/^RUN npm ci #{Regexp.escape(argument)}$/, "#{npm} npm ci #{argument}")
  end
  dockerfile.replace(/^RUN npm ci$/, "#{npm} npm ci")
  dockerfile.replace(/^RUN npm run build(?=\n\n# Production image\n)/, "RUN --mount=type=cache,id=infisical-ts-app,target=/app/.cache,sharing=locked --mount=type=cache,id=infisical-ts-node,target=/app/node_modules/.tmp,sharing=locked npm run build")
end
