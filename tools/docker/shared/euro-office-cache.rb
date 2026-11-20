require "digest"
require "find"

module EuroOfficeCache
  CCACHE_BINARIES = "COPY bench-ccache/ccache /usr/local/bin/ccache\nCOPY bench-ccache/ccache-storage-http /usr/local/bin/ccache-storage-http\n".freeze
  THIRD_PARTY_INPUTS = ["common.cmake", "Common/3dParty"].freeze

  def self.third_party_key(core)
    builder, recipes = THIRD_PARTY_INPUTS.map { File.join(core, it) }
    abort "core third-party builder changed: expected #{THIRD_PARTY_INPUTS.join(" and ")}" unless File.file?(builder) && File.directory?(recipes)

    files = [builder, *Find.find(recipes).select { File.file?(it) }].map { it.delete_prefix("#{core}/") }.sort
    files.each_with_object(Digest::SHA256.new) do |path, digest|
      digest << path << "\0" << Digest::SHA256.file(File.join(core, path)).hexdigest << "\0"
    end.hexdigest[0, 12]
  end

  def self.core(source, third_party:, local_cache: true)
    return build_script_core(source, third_party:, local_cache:) if source.include?("ARG CORE_CCACHE\n")

    replacements = {
      "FROM core-base AS core\n" => "FROM core-base AS core\n#{CCACHE_BINARIES}ENV CCACHE_DIR=/root/.cache/ccache\n",
      "-DCMAKE_BUILD_TYPE=Release \\\n" => "-DCMAKE_BUILD_TYPE=Release \\\n        -DCMAKE_C_COMPILER_LAUNCHER=ccache \\\n        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \\\n",
      "cmake --build . &&" => "ccache --zero-stats && cmake --build . && ccache --show-stats &&",
    }
    if local_cache
      replacements["RUN --mount=type=cache,target=/build-cache \\\n"] = "RUN --mount=type=cache,id=euro-office-core-ccache,target=/root/.cache/ccache \\\n        --mount=type=cache,target=/build-cache \\\n"
    end
    replace(source, replacements, "core")
  end

  def self.build_script_core(source, third_party:, local_cache:)
    replacements = {
      "FROM core-base AS core\n" => "FROM core-base AS core\n#{CCACHE_BINARIES}",
      "ARG CORE_CCACHE\n" => "ARG CORE_CCACHE=1\n",
      "RUN --mount=type=cache,target=/build-cache \\\n" => "RUN --mount=type=cache,id=build-cache-#{third_party},target=/build-cache \\\n",
    }
    replacements["        --mount=type=cache,target=/ccache,id=core-ccache \\\n"] = "" unless local_cache
    replace(source, replacements, "core")
  end

  def self.wasm(source, third_party:, local_cache: true)
    replacements = {
      "    COPY core /core\n" => "    COPY bench-ccache/ccache /usr/local/bin/ccache\n    COPY bench-ccache/ccache-storage-http /usr/local/bin/ccache-storage-http\n    ENV CCACHE_DIR=/ccache\n    COPY core /core\n",
      "id=wasm-build-cache-${CACHE_BUST},target=/build-cache-wasm" => "id=wasm-build-cache-${CACHE_BUST}-#{third_party},target=/build-cache-wasm",
    }
    unless source.include?("        ccache --zero-stats\n        /core/scripts/build.sh --wasm --ccache ")
      build = "        cmake --build . -- -j$(nproc)\n"
      replacements[build] = "        ccache --zero-stats\n#{build}"
    end
    replacements["        --mount=type=cache,id=wasm-ccache,target=/ccache \\\n"] = "" unless local_cache
    replace(source, replacements, "core-wasm")
  end

  def self.replace(source, replacements, target)
    replacements.reduce(source) do |content, (before, after)|
      abort "#{target} Dockerfile changed: expected one #{before.inspect}" unless content.scan(before).size == 1
      content.sub(before, after)
    end
  end
end
