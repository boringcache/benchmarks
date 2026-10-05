# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "rbconfig"
require_relative "../scripts/reapi-registry"

class ReapiRegistryTest < Minitest::Test
  def test_warm_registry_is_read_only_and_cache_errors_are_fatal
    args = ReapiRegistry.command(provider: "boringcache", phase: "warm", workspace: "boringcache/benchmarks", tag: "case-series")
    assert_includes args, "--read-only"
    assert_includes args, "--fail-on-cache-error"
    refute_includes ReapiRegistry.command(provider: "boringcache", phase: "cold", workspace: "boringcache/benchmarks", tag: "case-series"), "--read-only"
  end

  def test_failed_start_does_not_run_the_build
    Dir.mktmpdir do |directory|
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]
      server.close
      error = assert_raises(ReapiRegistry::Error) do
        ReapiRegistry.with_process([RbConfig.ruby, "-e", "exit 7"], port: port, log: "#{directory}/registry.log") { flunk "Build ran" }
      end
      assert_match(/before readiness/, error.message)
    end
  end

  def test_warm_comparator_requires_authentication_for_writes
    args = ReapiRegistry.command(provider: "bazel-remote", phase: "warm", workspace: "boringcache/benchmarks", tag: "case-series")
    assert_includes args, "--htpasswd_file"
    assert_includes args, "--allow_unauthenticated_reads"
  end

  def test_changed_source_registries_allow_reads_and_publication
    args = ReapiRegistry.command(provider: "boringcache", phase: "commit", workspace: "boringcache/benchmarks", tag: "case-series")
    refute_includes args, "--read-only"
    assert_includes args, "--fail-on-cache-error"
    args = ReapiRegistry.command(provider: "bazel-remote", phase: "commit", workspace: "boringcache/benchmarks", tag: "case-series")
    refute_includes args, "--htpasswd_file"
    assert_includes args, "reapi-store"
    assert_raises(ReapiRegistry::Error) { ReapiRegistry.command(provider: "boringcache", phase: "unknown", workspace: "boringcache/benchmarks", tag: "case-series") }
  end

  def test_failed_shutdown_fails_after_a_successful_build
    Dir.mktmpdir do |directory|
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]
      server.close
      code = 'require "socket"; trap("INT") { exit 7 }; s = TCPServer.new("127.0.0.1", Integer(ARGV[0])); sleep'
      built = false
      error = assert_raises(ReapiRegistry::Error) do
        ReapiRegistry.with_process([RbConfig.ruby, "-e", code, port.to_s], port: port, log: "#{directory}/registry.log") { built = true }
      end
      assert built
      assert_match(/shutdown failed/, error.message)
    end
  end
end
