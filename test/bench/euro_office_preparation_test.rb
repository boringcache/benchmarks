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
      assert_equal 9, reads.size
      assert_equal 9, writes.size
      assert reads.all? { it.include?(".cache-from=") }
      assert_equal 9, reads.map { it.split("=", 3).last }.uniq.size
      assert_equal reads.map { it.split(".").first }.sort, writes.map { it.split(".").first }.sort
    end
  end

  private
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
