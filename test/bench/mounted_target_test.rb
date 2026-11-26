require_relative "test_helper"

class MountedTargetTest < Minitest::Test
  def test_keeps_the_target_entry_so_the_adapter_records_mounted_source_freshness
    root = File.expand_path("../..", __dir__)
    %w[nushell zed codex ferrum-fuzz].each do |project|
      plan = TomlRB.load_file(File.join(root, "tools/cargo", project, "plus/.boringcache.toml"))
      expected = Marshal.load(Marshal.dump(plan))

      Bench::MountedTarget.require_target_entry(plan)

      assert_equal expected, plan
    end
    plan = { "entries" => {}, "profiles" => {} }
    assert_raises(Bench::Error) { Bench::MountedTarget.require_target_entry(plan) }
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

  def test_the_checksum_covers_the_smallest_library_at_any_depth_and_size
    Dir.mktmpdir do |root|
      mount = File.join(root, "target")
      deps = File.join(mount, "x86_64-unknown-linux-gnu", "release", "deps")
      FileUtils.mkdir_p([deps, File.join(root, "diagnostics")])
      File.write(File.join(deps, "libempty.rlib"), "")
      File.write(File.join(deps, "liblarge.rlib"), "x" * (3 * 1024 * 1024))
      File.write(File.join(deps, "liblarger.rlib"), "x" * (4 * 1024 * 1024))
      target = Bench::MountedTarget.allocate
      target.instance_variable_set(:@mount, mount)
      target.instance_variable_set(:@bazel, false)
      target.instance_variable_set(:@receipt, File.join(root, "diagnostics", "archive-mount.json"))

      target.send(:save_digest)

      recorded = File.read(File.join(root, "diagnostics", "archive-library.sha256"))
      assert_equal "#{Digest::SHA256.file(File.join(deps, 'liblarge.rlib')).hexdigest}  #{File.join(deps, 'liblarge.rlib')}\n", recorded
      FileUtils.rm([File.join(deps, "liblarge.rlib"), File.join(deps, "liblarger.rlib")])
      error = assert_raises(Bench::Error) { target.send(:save_digest) }
      assert_match "1 paths match", error.message
    end
  end

  def test_the_checksum_finds_libraries_in_the_build_directory_layout
    Dir.mktmpdir do |root|
      mount = File.join(root, "target")
      out = File.join(mount, "x86_64-unknown-linux-gnu", "release", "build", "itoa", "959b3b83ff293ec3", "out")
      FileUtils.mkdir_p([out, File.join(root, "diagnostics")])
      library = File.join(out, "libitoa-959b3b83ff293ec3.rlib")
      File.write(library, "rlib")
      target = Bench::MountedTarget.allocate
      target.instance_variable_set(:@mount, mount)
      target.instance_variable_set(:@bazel, false)
      target.instance_variable_set(:@receipt, File.join(root, "diagnostics", "archive-mount.json"))

      target.send(:save_digest)

      assert_equal "#{Digest::SHA256.file(library).hexdigest}  #{library}\n",
                   File.read(File.join(root, "diagnostics", "archive-library.sha256"))
    end
  end

  def test_the_fresh_mount_reruns_the_case_check_with_the_same_environment
    Dir.mktmpdir do |root|
      workspace = File.join(root, "work dir")
      FileUtils.mkdir_p([File.join(workspace, "target"), File.join(root, "diagnostics")])
      check = Bench::MountedTarget::Check.new(env: { "PATH" => ENV.fetch("PATH"), "BENCH_LANE" => "it's mounted" },
                                              command: 'test -x target/app && test "$BENCH_LANE" = "it'"'"'s mounted" && test -z "$HOME"',
                                              dir: workspace)
      target = Bench::MountedTarget.allocate
      target.instance_variable_set(:@bazel, false)
      target.instance_variable_set(:@receipt, File.join(root, "diagnostics", "archive-mount.json"))

      assert target.send(:save_check, check)
      script = File.join(root, "diagnostics", "archive-check.sh")
      refute check.call
      refute system("bash", script)
      File.write(File.join(workspace, "target", "app"), "")
      File.chmod(0o755, File.join(workspace, "target", "app"))
      assert check.call
      assert system("bash", script)
    end
  end

  def test_verification_time_is_recorded_apart_from_the_timed_build
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, "diagnostics"))
      target = Bench::MountedTarget.allocate
      target.instance_variable_set(:@verify_seconds, 0.0)
      previous = ENV["RUNNER_TEMP"]
      begin
        ENV["RUNNER_TEMP"] = root
        assert_nil Bench::MountedTarget.verify_seconds
        assert_equal :checked, target.send(:verifying) { sleep 0.05; :checked }
        assert_raises(Bench::Error) { target.send(:verifying) { raise Bench::Error, "mismatch" } }
        File.write(File.join(root, "diagnostics", "archive-verify-seconds"), target.instance_variable_get(:@verify_seconds).round(3).to_s)
        assert_operator Bench::MountedTarget.verify_seconds, :>=, 0.05
      ensure
        ENV["RUNNER_TEMP"] = previous
      end
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
