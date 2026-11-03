require "toml-rb"

plan = TomlRB.load_file(".boringcache.toml").fetch("adapters").fetch("docker")
exit unless plan["mount-cache"]

source = File.read("upstream/core/.docker/core.bake.Dockerfile")
replacements = {
  "FROM core-base AS core\n" => "FROM core-base AS core\nCOPY bench-ccache/ccache /usr/local/bin/ccache\nCOPY bench-ccache/ccache-storage-http /usr/local/bin/ccache-storage-http\nENV CCACHE_DIR=/root/.cache/ccache\n",
  "RUN --mount=type=cache,target=/build-cache \\\n" => "RUN --mount=type=cache,id=euro-office-core-ccache,target=/root/.cache/ccache \\\n        --mount=type=cache,target=/build-cache \\\n",
  "-DCMAKE_BUILD_TYPE=Release \\\n" => "-DCMAKE_BUILD_TYPE=Release \\\n        -DCMAKE_C_COMPILER_LAUNCHER=ccache \\\n        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \\\n",
  "cmake --build . &&" => "ccache --zero-stats && cmake --build . && ccache --show-stats &&",
}
replacements.each do |before, after|
  abort "core Dockerfile changed: expected one #{before.inspect}" unless source.scan(before).size == 1
  source = source.sub(before, after)
end
File.write("overlay/core.Dockerfile", source)
system("bash", File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/stage-ccache-binary.sh"), "upstream/bench-ccache", exception: true)
