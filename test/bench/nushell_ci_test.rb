require_relative "test_helper"

class NushellCiTest < Minitest::Test
  def test_cache_providers_run_the_same_cargo_commands
    native, native_status = run_ci
    cached, cached_status = run_ci("BENCH_BORINGCACHE" => "boringcache cargo")
    assert native_status.success?
    assert cached_status.success?
    assert_equal native.grep(/^cargo /), cached.grep(/^cargo /)
    calls = cached.grep(/^boringcache /)
    assert_equal 5, calls.size
    assert_includes calls.first, "--skip-save -- --config .cargo/ci.toml check"
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

  private
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
