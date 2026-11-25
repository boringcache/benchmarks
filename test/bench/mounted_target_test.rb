require_relative "test_helper"

class MountedTargetTest < Minitest::Test
  def test_replaces_only_the_target_and_keeps_sccache_and_dependency_tags
    root = File.expand_path("../..", __dir__)
    %w[nushell zed codex ferrum-fuzz].each do |project|
      plan = TomlRB.load_file(File.join(root, "tools/cargo", project, "plus/.boringcache.toml"))
      expected = plan.fetch("entries").reject { |_, entry| entry["kind"] == "cargo-target" }
      adapters = Marshal.load(Marshal.dump(plan.fetch("adapters")))
      Bench::MountedTarget.remove_archive(plan)
      assert_equal expected, plan.fetch("entries")
      assert_equal expected.keys, plan.dig("profiles", "cargo-product", "entries")
      assert_equal adapters, plan.fetch("adapters")
    end
  end
  def test_bazel_mount_uses_the_output_path_reported_by_the_benchmark_binary
    Dir.mktmpdir do |root|
      upstream = File.join(root, "upstream")
      Dir.mkdir(upstream)
      mount = File.join(root, "output base", "execroot", "_main", "bazel-out")
      binary = File.join(root, "bazel")
      File.write(binary, <<~SH)
        #!/bin/sh
        test "$1 $2 $3" = "--bazelrc=../bench.bazelrc info output_path" || exit 4
        cat ../reported-path
      SH
      File.chmod(0o755, binary)
      workspace = Struct.new(:upstream_dir).new(upstream)
      kase = Struct.new(:name, :tool).new("codex-incredibuild", Struct.new(:name).new("bazel"))
      previous = ENV["RUNNER_TEMP"]
      begin
        ENV["RUNNER_TEMP"] = root
        target = Bench::MountedTarget.new(kase, workspace, "trial", "cold")
        File.write(File.join(root, "reported-path"), mount + "\n")
        assert_equal mount, target.send(:bazel_output_path)
        File.write(File.join(root, "reported-path"), File.join(root, "upstream", "bazel-out"))
        assert_raises(Bench::Error) { target.send(:bazel_output_path) }
      ensure
        ENV["RUNNER_TEMP"] = previous
      end
    end
  end
end
