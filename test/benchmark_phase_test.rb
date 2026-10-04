# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "../scripts/benchmark-phase"

class BenchmarkPhaseTest < Minitest::Test
  def test_fresh_identity_is_shared_by_both_phases_and_isolated_between_samples
    env = {"BENCHMARK_ID" => "posthog", "CACHE_LANE" => "fresh", "BENCHMARK_SERIES_ID" => "screening-01",
      "BENCHMARK_SAMPLE" => "1", "GITHUB_RUN_ID" => "123", "GITHUB_RUN_ATTEMPT" => "2"}
    cold = BenchmarkPhase.scope(env.merge("PHASE" => "publish"))
    assert_equal "posthog-series-screening-01-s1-r123-a2", cold
    assert_equal cold, BenchmarkPhase.scope(env.merge("PHASE" => "warm"), require_published: true)
    refute_equal cold, BenchmarkPhase.scope(env.merge("BENCHMARK_SAMPLE" => "2"))
    refute_equal cold, BenchmarkPhase.scope(env.merge("GITHUB_RUN_ATTEMPT" => "3"))
    assert_equal "posthog-series-screening-01", BenchmarkPhase.scope(env.merge("CACHE_LANE" => "rolling"))
  end

  def test_warm_consumption_never_exports_and_explicit_publication_applies_to_both_providers
    cold = BenchmarkPhase.policy("publish", "false")
    warm = BenchmarkPhase.policy("warm", "false")
    advance = BenchmarkPhase.policy("warm", "true")
    assert_equal({"publish-cache" => true, "trust-policy" => "publish", "require-hit" => false}, cold)
    assert_equal({"publish-cache" => false, "trust-policy" => "restore", "require-hit" => true}, warm)
    assert_equal({"publish-cache" => true, "trust-policy" => "publish", "require-hit" => true}, advance)
    assert_raises(RuntimeError) { BenchmarkPhase.policy("other", "false") }
    assert_raises(RuntimeError) { BenchmarkPhase.policy("warm", "") }
    action = YAML.safe_load(File.read(File.expand_path("../.github/actions/docker-benchmark/action.yml", __dir__)))
    steps = action.dig("runs", "steps")
    actions = steps.find { |step| step["uses"].to_s.start_with?("docker/build-push-action@") }.fetch("with")
    product = steps.find { |step| step["id"] == "provider" }.fetch("with")
    assert_includes actions.fetch("cache-to"), "steps.policy.outputs.publish-cache == 'true'"
    assert_equal "${{ steps.policy.outputs.trust-policy }}", product.fetch("trust-policy")
    assert_equal "${{ steps.policy.outputs.require-hit }}", product.fetch("fail-on-cache-miss")
    assert_equal "build_timing", steps.last.fetch("id")
    Dir[File.expand_path("../cases/*/payload/.github/actions/*/action.yml", __dir__)].each do |path|
      refute_includes File.read(path), "docker/build-push-action@", "#{path}: Docker provider lifecycle must be shared"
    end
  end
end
