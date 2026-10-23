require_relative "test_helper"

class FuzzSmokeTest < Minitest::Test
  TARGETS = %w[traceparent config_decode proxy_protocol mesh_udp_frame k8s_crd plugin_config ocsp_response jwt_svid tls_material datagram_client_address].freeze

  def test_verified_executables_are_removed_before_the_next_build
    run_smoke do |dir, status|
      assert status.success?
      assert_equal TARGETS, File.readlines(File.join(dir, "fuzz-verified"), chomp: true)
      assert_empty Dir.glob(File.join(dir, "target/x86_64-unknown-linux-gnu/release/deps/traceparent-*"))
      assert File.exist?(File.join(dir, "target/x86_64-unknown-linux-gnu/release/deps/libshared.rlib"))
    end
  end

  def test_failure_does_not_verify_or_delete_the_failed_target
    run_smoke("FAIL_TARGET" => "config_decode") do |dir, status|
      refute status.success?
      assert_equal ["traceparent"], File.readlines(File.join(dir, "fuzz-verified"), chomp: true)
      assert File.executable?(File.join(dir, "target/x86_64-unknown-linux-gnu/release/config_decode"))
    end
  end

  def test_missing_executable_is_not_verified
    run_smoke("MISSING_TARGET" => "traceparent") do |dir, status|
      refute status.success?
      refute File.exist?(File.join(dir, "fuzz-verified"))
    end
  end

  private
    def run_smoke(extra_env = {})
      Dir.mktmpdir("fuzz-smoke") do |dir|
        FileUtils.mkdir_p(File.join(dir, "bin"))
        cargo = File.join(dir, "bin/cargo")
        File.write(cargo, <<~BASH)
          #!/usr/bin/env bash
          set -euo pipefail
          [ "$1" = test ] && exit 0
          target=$5
          release="$CARGO_TARGET_DIR/x86_64-unknown-linux-gnu/release"
          test ! -d "$release/build/ferrum-edge-fuzz"
          mkdir -p "$release/build/ferrum-edge-fuzz/unit/out" "$release/deps"
          touch "$release/deps/libshared.rlib" "$release/deps/$target-old"
          if [ "$target" != "${MISSING_TARGET:-}" ]; then
            touch "$release/$target"
            chmod +x "$release/$target"
          fi
          [ "$target" != "${FAIL_TARGET:-}" ]
        BASH
        File.chmod(0o755, cargo)
        File.write(File.join(dir, "fuzz-verified"), "stale\n")
        env = { "PATH" => "#{dir}/bin:#{ENV.fetch('PATH')}", "BENCH_DIR" => dir,
          "CARGO_TARGET_DIR" => File.join(dir, "target"), "BENCH_BORINGCACHE" => nil, **extra_env }
        _output, status = Open3.capture2e(env, "bash", File.join(Bench::ROOT, "tools/cargo/ferrum-fuzz/overlay/fuzz-smoke.sh"))
        yield dir, status
      end
    end
end
