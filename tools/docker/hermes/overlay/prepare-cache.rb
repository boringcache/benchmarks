require File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/cache-overlay")

CacheOverlay.apply("upstream/Dockerfile") do |dockerfile|
  pnpm = "RUN --mount=type=cache,id=hermes-pnpm,target=/var/cache/pnpm,sharing=locked pnpm_config_store_dir=/var/cache/pnpm"
  dockerfile.replace(/^RUN (node scripts\/build\/node-deps\.mjs --source \/opt\/hermes --workspace ui-tui --workspace web &&)/, "#{pnpm} \\1")
  dockerfile.replace(/^RUN (node apps\/desktop\/scripts\/build-webapp\.mjs --deps-only)$/, "#{pnpm} \\1")
end
