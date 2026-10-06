# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "open3"
require_relative "../cases/grpc/payload/scripts/grpc-bazel-evidence"
require_relative "../scripts/benchmark-cadence"
require_relative "../scripts/benchmark-phase"

class GrpcBazelEvidenceTest < Minitest::Test
  def test_scheduled_rolling_keeps_the_populated_cache_across_harness_refs
    inputs = BenchmarkCadence.rolling_targets(case_id: "grpc").fetch(0).fetch("inputs")
    assert_equal "main", inputs.fetch("cache_scope")
    environment = {"BENCHMARK_ID" => "grpc-bazel", "CACHE_LANE" => "rolling",
      "BENCHMARK_ROLLING_SCOPE" => inputs.fetch("cache_scope")}
    %w[main benchmark-updated-harness].each do |ref|
      assert_equal "grpc-bazel-rolling-main", BenchmarkPhase.scope(environment.merge("GITHUB_REF_NAME" => ref))
    end
  end

  def test_native_processes_distinguish_cache_reuse_from_provider_setup
    cold = GrpcBazelEvidence.read("INFO: 6378 processes: 2588 internal, 3790 processwrapper-sandbox.\n")
    refute cold.fetch("hit")
    assert_equal 0, cold.fetch("cache_hit_processes")
    warm = GrpcBazelEvidence.read("INFO: 6378 processes: 2588 internal, 3790 remote cache hit.\n")
    assert warm.fetch("hit")
    assert_equal 3790, warm.fetch("cache_hit_processes")
    mixed = GrpcBazelEvidence.read("\e[32mINFO: 9 processes: 2 internal, 3 disk cache hit, 1 remote cache hit, 3 processwrapper-sandbox.\e[0m\n")
    assert_equal 4, mixed.fetch("cache_hit_processes")
    assert_equal 3, mixed.fetch("processes").fetch("processwrapper-sandbox")
  end

  def test_missing_or_invalid_native_counters_cannot_become_a_hit
    assert_nil GrpcBazelEvidence.read("Cache restored successfully\n").fetch("hit")
    assert_raises(RuntimeError) { GrpcBazelEvidence.read("INFO: 9 processes: 10 remote cache hit.\n") }
  end

  def test_warm_miss_retains_evidence_and_fails_verification
    Dir.mktmpdir do |directory|
      log, output = File.join(directory, "build.log"), File.join(directory, "output")
      File.write(log, "INFO: 2 processes: 2 processwrapper-sandbox.\n")
      script = File.expand_path("../cases/grpc/payload/scripts/grpc-bazel-evidence.rb", __dir__)
      _, error, status = Open3.capture3({"PHASE" => "warm", "GITHUB_OUTPUT" => output}, RbConfig.ruby, script, log, chdir: directory)
      refute status.success?
      assert_includes error, "did not report native cache reuse"
      assert_equal "cache_hit=false\n", File.read(output)
      refute JSON.parse(File.read(File.join(directory, "benchmark-results/bazel/cache-evidence.json"))).fetch("hit")
    end
  end
end
