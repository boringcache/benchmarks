require_relative "test_helper"

class NushellCiTest < Minitest::Test
  def test_cache_providers_run_the_same_cargo_commands
    native, native_status = run_ci
    cached, cached_status = run_ci("BENCH_BORINGCACHE" => "boringcache cargo")
    assert native_status.success?
    assert cached_status.success?
    assert_equal native.grep(/^cargo /), cached.grep(/^cargo /)
    calls = cached.grep(/^boringcache /)
    assert_equal 3, calls.size
    assert_includes calls.first, "--skip-save -- --config .cargo/ci.toml build"
    refute_includes calls.first, "--skip-restore"
    assert calls.drop(1).all? { it.include?("--skip-restore") }
    assert_includes calls.last, "test --workspace --doc --profile ci"
    refute_includes calls.last, "--skip-save"
  end

  def test_warm_commands_all_keep_read_only
    calls, status = run_ci("BENCH_BORINGCACHE" => "boringcache cargo --read-only")
    assert status.success?
    assert calls.grep(/^boringcache /).all? { it.include?("--read-only") }
  end

  def test_failed_test_stops_before_doctests_and_save
    calls, status = run_ci("BENCH_BORINGCACHE" => "boringcache cargo", "FAIL_COMMAND" => "test")
    assert_equal 42, status.exitstatus
    refute calls.any? { it.include?("--doc") }
    assert calls.grep(/^boringcache /).all? { it.include?("--skip-save") }
  end

  def test_output_check_accepts_native_and_windows_executables
    ["nu", "nu.exe"].each do |name|
      output_check(name:) do |dir, status|
        assert status.success?
        File.write(File.join(dir, "upstream/changed.txt"), "changed")
        _, dirty_status = Open3.capture2e("bash", check_script, chdir: dir)
        refute dirty_status.success?
      end
    end
  end

  def test_output_check_requires_a_working_executable
    output_check(name: nil) { |_, status| refute status.success? }
    output_check(name: "nu.exe", exit_status: 1) { |_, status| refute status.success? }
  end

  private
    def check_script
      File.join(Bench::ROOT, "tools/cargo/nushell/overlay/check.sh")
    end

    def output_check(name:, exit_status: 0)
      Dir.mktmpdir("nu-check") do |dir|
        upstream = File.join(dir, "upstream")
        FileUtils.mkdir_p(File.join(upstream, "target/ci"))
        Bench.git("init", "--quiet", chdir: upstream)
        File.write(File.join(upstream, ".git/info/exclude"), "/target/\n")
        if name
          binary = File.join(upstream, "target/ci", name)
          File.write(binary, "#!/usr/bin/env bash\nexit #{exit_status}\n")
          File.chmod(0o755, binary)
        end
        _, status = Open3.capture2e("bash", check_script, chdir: dir)
        yield dir, status
      end
    end

    def run_ci(extra_env = {})
      Dir.mktmpdir("nushell-ci") do |dir|
        File.write(File.join(dir, "cargo"), <<~BASH)
          #!/usr/bin/env bash
          printf 'cargo %s\n' "$*" >> "$CALLS"
          [ "$1" != --config ] || shift 2
          [ "$1" != "${FAIL_COMMAND:-}" ] || exit 42
        BASH
        File.write(File.join(dir, "boringcache"), <<~BASH)
          #!/usr/bin/env bash
          printf 'boringcache %s\n' "$*" >> "$CALLS"
          while [ "$1" != -- ]; do shift; done
          shift
          exec cargo "$@"
        BASH
        File.chmod(0o755, File.join(dir, "cargo"), File.join(dir, "boringcache"))
        env = { "PATH" => "#{dir}:#{ENV.fetch('PATH')}", "CALLS" => File.join(dir, "calls"),
          "BENCH_BORINGCACHE" => nil, "FAIL_COMMAND" => nil, **extra_env }
        _, status = Open3.capture2e(env, "bash", File.join(Bench::ROOT, "tools/cargo/nushell/overlay/ci.sh"))
        [File.readlines(env.fetch("CALLS"), chomp: true), status]
      end
    end
end
