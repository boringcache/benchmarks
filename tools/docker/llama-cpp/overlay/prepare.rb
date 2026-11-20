source, output = ARGV
prepare = ARGV.empty?
if prepare
  require "toml-rb"
  plan = TomlRB.load_file(".boringcache.toml").fetch("adapters").fetch("docker")
  exit if Array(plan["tool-cache"]).empty?

  source = "upstream/.devops/cuda.Dockerfile"
  output = "overlay/llama-cpp-ccache.Dockerfile"
end
dockerfile = File.read(source)

stage = 'FROM ${BASE_CUDA_DEV_CONTAINER} AS build'
compile = 'RUN if [ "${CUDA_DOCKER_ARCH}" != "default" ]; then'
configure = 'cmake -B build '
build = /^    cmake --build build [^\n]+$/
launchers = %w[C CXX CUDA].map { |language| "-DCMAKE_#{language}_COMPILER_LAUNCHER=ccache" }.join(" ")

replacements = {
  stage => <<~DOCKERFILE.chomp,
    #{stage}

    COPY bench-ccache/ccache /usr/bin/ccache
    COPY bench-ccache/ccache-storage-http /usr/bin/ccache-storage-http
    ENV CCACHE_COMPILERCHECK=content
  DOCKERFILE
  compile => "RUN --mount=type=cache,id=llama-cpp-ccache,target=/root/.cache/ccache #{compile.delete_prefix("RUN ")}",
  configure => "#{configure}#{launchers} ",
  build => "\\0 && ccache --show-stats",
}

replacements.each do |before, after|
  abort "llama.cpp CUDA Dockerfile changed: expected one #{before.inspect}" unless dockerfile.scan(before).size == 1
  dockerfile.sub!(before, after)
end

File.write(output, dockerfile)
if prepare
  system("bash", File.join(ENV.fetch("BENCH_ROOT"), "tools/docker/shared/stage-ccache-binary.sh"),
    "upstream/bench-ccache", exception: true)
end
