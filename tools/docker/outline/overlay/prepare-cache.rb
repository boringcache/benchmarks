require File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/cache-overlay")

CacheOverlay.apply("upstream/Dockerfile.base") do |dockerfile|
  yarn = "RUN --mount=type=cache,id=outline-yarn,target=/var/cache/yarn,sharing=locked YARN_ENABLE_GLOBAL_CACHE=false YARN_ENABLE_MIRROR=false YARN_CACHE_FOLDER=/var/cache/yarn"
  dockerfile.replace(/^RUN yarn install --immutable --network-timeout 1000000 && \\\n  yarn cache clean$/, "#{yarn} yarn install --immutable --network-timeout 1000000")
  dockerfile.replace(/^RUN yarn workspaces focus --production && \\\n  yarn cache clean$/, "#{yarn} yarn workspaces focus --production")
end
