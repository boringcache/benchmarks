# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require "open3"
require "tmpdir"
require "rbconfig"
require_relative "../scripts/benchmark-phase"

class BenchmarkPhaseTest < Minitest::Test
  def test_policy_entrypoint_writes_consumable_action_outputs
    Dir.mktmpdir("benchmark-policy-") do |directory|
      path = File.join(directory, "outputs")
      [["publish", "false"], ["warm", "false"], ["warm", "true"]].each do |phase, publish|
        File.write(path, "")
        output, status = Open3.capture2e({"GITHUB_OUTPUT" => path, "PHASE" => phase, "PUBLISH_ON_WARM" => publish},
          RbConfig.ruby, File.expand_path("../scripts/benchmark-phase.rb", __dir__), "policy")
        assert status.success?, output
        values = File.readlines(path).to_h { |line| line.strip.split("=", 2) }
        assert_equal BenchmarkPhase.policy(phase, publish).transform_values(&:to_s), values
      end
    end
  end

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
    assert_equal({"publish_cache" => true, "require_hit" => false}, cold)
    assert_equal({"publish_cache" => false, "require_hit" => true}, warm)
    assert_equal({"publish_cache" => true, "require_hit" => true}, advance)
    assert_raises(RuntimeError) { BenchmarkPhase.policy("other", "false") }
    assert_raises(RuntimeError) { BenchmarkPhase.policy("warm", "") }
    action = YAML.safe_load(File.read(File.expand_path("../.github/actions/docker-benchmark/action.yml", __dir__)))
    steps = action.dig("runs", "steps")
    actions = steps.find { |step| step["uses"].to_s.start_with?("docker/build-push-action@") }.fetch("with")
    publish = steps.find { |step| step["id"] == "publish" }
    restore = steps.find { |step| step["id"] == "restore" }
    assert_includes actions.fetch("cache-to"), "steps.policy.outputs.publish_cache == 'true'"
    assert_equal "publish", publish.dig("with", "trust-policy")
    assert_equal "restore", restore.dig("with", "trust-policy")
    assert_includes publish.fetch("if"), "steps.policy.outputs.publish_cache == 'true'"
    assert_includes restore.fetch("if"), "steps.policy.outputs.publish_cache == 'false'"
    [publish, restore].each do |step|
      assert_equal "${{ steps.policy.outputs.require_hit }}", step.dig("with", "fail-on-cache-miss")
    end
    assert_equal "build_timing", steps.last.fetch("id")
    Dir[File.expand_path("../cases/*/payload/.github/actions/*/action.yml", __dir__)].each do |path|
      refute_includes File.read(path), "docker/build-push-action@", "#{path}: Docker provider lifecycle must be shared"
    end
  end

  def test_explicit_rolling_cohort_links_frozen_source_generations_without_changing_fresh_identity
    env = {"BENCHMARK_ID" => "posthog", "CACHE_LANE" => "rolling", "BENCHMARK_SERIES_ID" => "parent-01",
      "BENCHMARK_SAMPLE" => "1", "BENCHMARK_ROLLING_SCOPE" => "qualification-01", "GITHUB_RUN_ID" => "123", "GITHUB_RUN_ATTEMPT" => "1"}
    assert_equal "posthog-rolling-qualification-01", BenchmarkPhase.scope(env)
    assert_equal BenchmarkPhase.scope(env), BenchmarkPhase.scope(env.merge("BENCHMARK_SERIES_ID" => "child-01", "GITHUB_RUN_ID" => "456"))
    fresh = env.merge("CACHE_LANE" => "fresh")
    assert_equal BenchmarkPhase.scope(fresh.reject { |key, _| key == "BENCHMARK_ROLLING_SCOPE" }), BenchmarkPhase.scope(fresh)
    assert_raises(RuntimeError) { BenchmarkPhase.scope(env.merge("BENCHMARK_ROLLING_SCOPE" => "../other")) }
  end
end
