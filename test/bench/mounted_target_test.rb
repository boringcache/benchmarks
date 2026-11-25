require_relative "test_helper"

class MountedTargetTest < Minitest::Test
  def test_replaces_only_the_target_and_keeps_sccache_dependencies_and_pruning
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

  def test_a_seed_needs_complete_pruning_usage
    Dir.mktmpdir do |root|
      mount = File.join(root, "target")
      FileUtils.mkdir_p(File.join(mount, ".boringcache"))
      target = Bench::MountedTarget.allocate
      target.instance_variable_set(:@mount, mount)

      assert_raises(Bench::Error) { target.send(:check_seed_usage) }
      record = File.join(mount, ".boringcache", "cargo-pruning-v1.json")
      File.write(record, JSON.generate("version" => 1, "complete" => false, "groups" => { "debug/a" => {} }))
      assert_raises(Bench::Error) { target.send(:check_seed_usage) }
      File.write(record, JSON.generate("version" => 1, "complete" => true, "groups" => { "debug/a" => {} }))
      target.send(:check_seed_usage)
    end
  end

  def test_a_rolling_build_needs_a_verified_root_to_reuse_another_runs_scope
    keys = %w[GITHUB_RUN_ID BENCH_ZED_SEED_ROOT RUNNER_TEMP]
    previous = ENV.to_h.slice(*keys)
    Dir.mktmpdir do |root|
      ENV.update("GITHUB_RUN_ID" => "101", "BENCH_ZED_SEED_ROOT" => nil, "RUNNER_TEMP" => root)
      kase = Struct.new(:name, :tool).new("zed", Struct.new(:name).new("cargo"))
      assert_raises(Bench::Error) { Bench::MountedTarget.new(kase, nil, "test-100", "rolling") }
      Bench::MountedTarget.new(kase, nil, "test-101", "rolling")
      ENV["BENCH_ZED_SEED_ROOT"] = "sha256:#{'a' * 64}"
      Bench::MountedTarget.new(kase, nil, "test-100", "rolling")
    end
  ensure
    keys.each { |key| ENV[key] = previous[key] }
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
