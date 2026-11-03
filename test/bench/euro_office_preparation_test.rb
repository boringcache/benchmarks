require_relative "test_helper"
require "open3"

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
    %w[gha ghcr].each do |provider|
      lane = TomlRB.load_file(File.join(Bench::ROOT, "tools/docker/lanes/#{provider}-bake-euro-office.toml"))
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

  private
    def prepare_standalone(resolve: true)
      Dir.mktmpdir("euro-office") do |dir|
        %w[upstream overlay bin].each { FileUtils.mkdir_p(File.join(dir, it)) }
        File.write(File.join(dir, "upstream/VERSION"), "9.3.6-rc.1\n")
        definition = { "target" => {
          "core" => { "context" => "upstream", "dockerfile" => "core/.docker/core.bake.Dockerfile", "args" => { "BUILD_ROOT" => "/package" }, "cache-from" => [{ "type" => "local", "src" => ".cache/core" }], "cache-to" => [{ "type" => "local", "dest" => ".cache/core" }] },
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
        script = File.join(Bench::ROOT, "tools/docker/euro-office/overlay/prepare.rb")
        output, status = Open3.capture2e({ "PATH" => "#{dir}/bin:#{ENV.fetch("PATH")}" }, RbConfig.ruby, script, chdir: dir)
        yield dir, definition, output, status
      end
    end

    def prepare_core(plus: true, replace: nil)
      Dir.mktmpdir("euro-office") do |dir|
        FileUtils.mkdir_p(File.join(dir, "upstream/core/.docker"))
        FileUtils.mkdir_p(File.join(dir, "overlay"))
        source = <<~DOCKERFILE
          FROM core-base AS core
          COPY core /core
          RUN --mount=type=cache,target=/build-cache \\
              --mount=type=cache,target=/nuget-cache,id=vcpkg-binary-cache \\
              cmake -DCMAKE_BUILD_TYPE=Release \\
              /core && cmake --build . && cp -r package/* /package
        DOCKERFILE
        source = source.sub("cmake --build .", replace) if replace
        File.write(File.join(dir, "upstream/core/.docker/core.bake.Dockerfile"), source)
        File.write(File.join(dir, ".boringcache.toml"), "[adapters.docker]\nmount-cache = #{plus}\n")
        helper = File.join(dir, "tools/docker/shared/stage-ccache-binary.sh")
        FileUtils.mkdir_p(File.dirname(helper))
        File.write(helper, "touch staged\n")
        script = File.join(Bench::ROOT, "tools/docker/euro-office-core/overlay/prepare.rb")
        output, status = Open3.capture2e({ "BENCH_ROOT" => dir }, RbConfig.ruby, script, chdir: dir)
        yield dir, source, output, status
      end
    end
end
