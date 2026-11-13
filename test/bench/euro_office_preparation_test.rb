require_relative "test_helper"
require "open3"
require_relative "../../tools/docker/shared/euro-office-cache"

class EuroOfficePreparationTest < Minitest::Test
  def test_plus_preserves_source_and_adds_compiler_and_mount_caches
    prepare_core do |dir, source, output, status|
      assert status.success?, output
      assert_equal source, File.read(File.join(dir, "upstream/core/.docker/core.bake.Dockerfile"))
      dockerfile = File.read(File.join(dir, "overlay/core.Dockerfile"))
      assert_includes dockerfile, "-DCMAKE_C_COMPILER_LAUNCHER=ccache"
      assert_includes dockerfile, "-DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
      assert_includes dockerfile, "id=euro-office-core-ccache,target=/root/.cache/ccache"
      assert_includes dockerfile, "target=/build-cache"
      assert_includes dockerfile, "id=vcpkg-binary-cache"
      assert_includes dockerfile, "cmake --build ."
    end
  end

  def test_plus_turns_on_the_upstream_ccache_switch_of_the_build_script_core
    prepare_core(source: build_script_core_source) do |dir, source, output, status|
      assert status.success?, output
      assert_equal source, File.read(File.join(dir, "upstream/core/.docker/core.bake.Dockerfile"))
      dockerfile = File.read(File.join(dir, "overlay/core.Dockerfile"))
      assert_includes dockerfile, "FROM core-base AS core\nCOPY bench-ccache/ccache /usr/local/bin/ccache\nCOPY bench-ccache/ccache-storage-http /usr/local/bin/ccache-storage-http\n"
      assert_includes dockerfile, "    ARG CORE_CCACHE=1\n"
      assert_includes dockerfile, "--mount=type=cache,target=/ccache,id=core-ccache"
      assert_includes dockerfile, "id=vcpkg-binary-cache"
      assert_equal source.lines.size + 2, dockerfile.lines.size
    end
  end

  def test_build_script_core_without_its_ccache_switch_stops_preparation
    prepare_core(source: build_script_core_source.sub("    ARG CORE_CCACHE\n", "")) do |dir, _, output, status|
      refute status.success?
      assert_includes output, "core Dockerfile changed"
      refute File.exist?(File.join(dir, "overlay/core.Dockerfile"))
    end
  end

  def test_changed_compile_step_stops_preparation
    prepare_core(replace: "cmake --build . --parallel") do |dir, _, output, status|
      refute status.success?
      assert_includes output, "core Dockerfile changed"
      refute File.exist?(File.join(dir, "overlay/core.Dockerfile"))
    end
  end

  def test_base_does_not_generate_an_overlay_or_stage_ccache
    prepare_core(plus: false) do |dir, _, output, status|
      assert status.success?, output
      refute File.exist?(File.join(dir, "overlay/core.Dockerfile"))
      refute File.exist?(File.join(dir, "staged"))
    end
  end

  def test_bake_lanes_keep_separate_target_caches_and_warm_does_not_publish
    %w[gha-bake-euro-office ghcr-bake-euro-office ghcr-bake-euro-office-plus].each do |name|
      lane = TomlRB.load_file(File.join(Bench::ROOT, "tools/docker/lanes/#{name}.toml"))
      reads = lane.fetch("warm").fetch("args")
      writes = lane.fetch("args").grep(/\.cache-to=/)
      assert_equal 10, reads.size
      assert_equal 10, writes.size
      assert reads.all? { it.include?(".cache-from=") }
      assert_equal 10, reads.map { it.split("=", 3).last }.uniq.size
      assert_equal reads.map { it.split(".").first }.sort, writes.map { it.split(".").first }.sort
    end
  end

  def test_standalone_keeps_resolved_build_inputs_without_embedded_cache_backends
    prepare_standalone do |dir, definition, output, status|
      assert status.success?, output
      actual = JSON.parse(File.read(File.join(dir, "overlay/build.json")))
      expected = Marshal.load(Marshal.dump(definition))
      expected.fetch("target").each_value { it.delete("cache-from"); it.delete("cache-to") }
      assert_equal expected, actual
      args = JSON.parse(File.read(File.join(dir, "overlay/version.json"))).dig("target", "_common", "args")
      assert_equal({ "PRODUCT_VERSION" => "9.3.6", "BUILD_NUMBER" => "0~rc.1", "OS_UPDATE_STAMP" => "2026-11-03" }, args)
      command = TomlRB.load_file(File.join(Bench::ROOT, "tools/docker/euro-office/.boringcache.toml")).dig("adapters", "docker", "command")
      refute command.any? { it.match?(/cache-(from|to)/) }
    end
  end

  def test_failed_bake_resolution_stops_preparation
    prepare_standalone(resolve: false) do |dir, _, output, status|
      refute status.success?
      assert_includes output, "Cannot resolve standalone Bake targets"
      refute File.exist?(File.join(dir, "overlay/build.json"))
    end
  end

  def test_combined_cache_keeps_build_state_without_archiving_remote_compiler_results
    prepare_standalone(plus: true) do |dir, _, output, status|
      assert status.success?, output
      targets = JSON.parse(File.read(File.join(dir, "overlay/build.json"))).fetch("target")
      core = File.read(File.join(dir, "overlay/core.Dockerfile"))
      wasm = File.read(File.join(dir, "overlay/core-wasm.Dockerfile"))
      assert_includes core, "-DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
      assert_includes core, "target=/build-cache"
      refute_includes core, "target=/root/.cache/ccache"
      assert_includes wasm, "target=/build-cache-wasm"
      assert_includes wasm, "target=/em-cache"
      refute_includes wasm, "target=/ccache"
      assert_includes wasm, "COPY bench-ccache/ccache /usr/local/bin/ccache"
      assert_includes wasm, "ccache --zero-stats"
      assert File.exist?(File.join(dir, "staged"))
      assert_equal "2", targets.dig("core-wasm", "args", "CACHE_BUST")
      assert_equal "../overlay/core.Dockerfile", targets.dig("core", "dockerfile")
    end
  end

  def test_native_control_archives_compiler_caches_as_well_as_build_state
    prepare_standalone(plus: true, local_cache: true) do |dir, _, output, status|
      assert status.success?, output
      targets = JSON.parse(File.read(File.join(dir, "overlay/build.json"))).fetch("target")
      assert_includes File.read(File.join(dir, "overlay/core.Dockerfile")), "target=/root/.cache/ccache"
      assert_includes File.read(File.join(dir, "overlay/core-wasm.Dockerfile")), "id=wasm-ccache,target=/ccache"
    end
  end

  def test_combined_cache_leaves_the_build_script_core_compiler_cache_remote
    prepare_standalone(plus: true, core: build_script_core_source) do |dir, _, output, status|
      assert status.success?, output
      core = File.read(File.join(dir, "overlay/core.Dockerfile"))
      assert_includes core, "    ARG CORE_CCACHE=1\n"
      assert_includes core, "target=/build-cache"
      refute_includes core, "target=/ccache"
    end
  end

  def test_native_control_keeps_the_build_script_core_compiler_cache_mount
    prepare_standalone(plus: true, local_cache: true, core: build_script_core_source) do |dir, _, output, status|
      assert status.success?, output
      assert_includes File.read(File.join(dir, "overlay/core.Dockerfile")), "--mount=type=cache,target=/ccache,id=core-ccache"
    end
  end

  private
    def prepare_standalone(resolve: true, plus: false, local_cache: false, core: core_source)
      Dir.mktmpdir("euro-office") do |dir|
        %w[upstream/core/.docker overlay bin].each { FileUtils.mkdir_p(File.join(dir, it)) }
        File.write(File.join(dir, "upstream/VERSION"), "9.3.6-rc.1\n")
        File.write(File.join(dir, ".boringcache.toml"), "[adapters.docker]\ntool-cache = #{plus ? '["ccache:test"]' : '[]'}\n")
        File.write(File.join(dir, "upstream/core/.docker/core.bake.Dockerfile"), core)
        File.write(File.join(dir, "upstream/core/.docker/core-wasm.bake.Dockerfile"), <<~'DOCKERFILE')
          FROM emsdk AS core-wasm
              COPY core /core
              RUN --mount=type=cache,id=wasm-build-cache-${CACHE_BUST},target=/build-cache-wasm \
                  --mount=type=cache,id=wasm-ccache,target=/ccache \
                  --mount=type=cache,id=wasm-em-cache,target=/em-cache <<EOF
                  cmake --build . -- -j$(nproc)
                  ccache --show-stats
          EOF
        DOCKERFILE
        definition = { "target" => {
          "core" => { "context" => "upstream", "dockerfile" => "core/.docker/core.bake.Dockerfile", "args" => { "BUILD_ROOT" => "/package" }, "cache-from" => [{ "type" => "local", "src" => ".cache/core" }], "cache-to" => [{ "type" => "local", "dest" => ".cache/core" }] },
          "core-wasm" => { "context" => "upstream", "dockerfile" => "core/.docker/core-wasm.bake.Dockerfile", "args" => { "CACHE_BUST" => "2" } },
          "standalone" => { "context" => "upstream", "contexts" => { "core" => "target:core" }, "tags" => ["euro-office-benchmark:local"], "output" => [{ "type" => "docker" }], "cache-from" => [{ "type" => "local", "src" => ".cache/docs" }] },
        } }
        File.write(File.join(dir, "bin/git"), "#!/bin/sh\nprintf '2026-11-03\\n'\n")
        File.write(File.join(dir, "bin/docker"), <<~RUBY)
          #!#{RbConfig.ruby}
          abort "Expected Bake inspection" unless ARGV[0, 2] == %w[buildx bake] && ARGV.include?("--print")
          exit 1 unless #{resolve}
          puts #{JSON.generate(definition).inspect}
        RUBY
        %w[git docker].each { File.chmod(0o755, File.join(dir, "bin", it)) }
        stage_stub(dir)
        script = File.join(Bench::ROOT, "tools/docker/shared/prepare-euro-office.rb")
        output, status = Open3.capture2e({ "PATH" => "#{dir}/bin:#{ENV.fetch("PATH")}", "BENCH_ROOT" => dir, "EURO_OFFICE_LOCAL_CCACHE" => local_cache ? "1" : nil }, RbConfig.ruby, script, chdir: dir)
        yield dir, definition, output, status
      end
    end

    def prepare_core(plus: true, replace: nil, source: core_source)
      Dir.mktmpdir("euro-office") do |dir|
        FileUtils.mkdir_p(File.join(dir, "upstream/core/.docker"))
        FileUtils.mkdir_p(File.join(dir, "overlay"))
        source = source.sub("cmake --build .", replace) if replace
        File.write(File.join(dir, "upstream/core/.docker/core.bake.Dockerfile"), source)
        File.write(File.join(dir, ".boringcache.toml"), "[adapters.docker]\nmount-cache = #{plus}\n")
        stage_stub(dir)
        FileUtils.cp(File.join(Bench::ROOT, "tools/docker/shared/euro-office-cache.rb"), File.join(dir, "tools/docker/shared"))
        script = File.join(Bench::ROOT, "tools/docker/euro-office-core/overlay/prepare.rb")
        output, status = Open3.capture2e({ "BENCH_ROOT" => dir }, RbConfig.ruby, script, chdir: dir)
        yield dir, source, output, status
      end
    end

    def core_source
      <<~DOCKERFILE
        FROM core-base AS core
        COPY core /core
        RUN --mount=type=cache,target=/build-cache \\
            --mount=type=cache,target=/nuget-cache,id=vcpkg-binary-cache \\
            cmake -DCMAKE_BUILD_TYPE=Release \\
            /core && cmake --build . && cp -r package/* /package
      DOCKERFILE
    end

    def build_script_core_source
      <<~'DOCKERFILE'
        FROM core-base AS core

            COPY core /core

            ARG CORE_CCACHE
            RUN --mount=type=cache,target=/build-cache \
                --mount=type=cache,target=/nuget-cache,id=vcpkg-binary-cache \
                --mount=type=cache,target=/ccache,id=core-ccache \
                --mount=type=secret,id=remote_cache_s3_access_key \
                export CCACHE_DIR=/ccache CCACHE_MAXSIZE=2G && \
                mkdir -p ${BUILD_ROOT} && \
                ${CORE_CCACHE:+ccache --zero-stats} && \
                /core/scripts/build.sh --build-dir /build-cache --output /build-cache/package ${CORE_CCACHE:+--ccache} && \
                ${CORE_CCACHE:+ccache --show-stats} && \
                cp -r /build-cache/package/* ${BUILD_ROOT}
      DOCKERFILE
    end

    def stage_stub(dir)
      helper = File.join(dir, "tools/docker/shared/stage-ccache-binary.sh")
      FileUtils.mkdir_p(File.dirname(helper))
      File.write(helper, "touch staged\n")
    end
end
