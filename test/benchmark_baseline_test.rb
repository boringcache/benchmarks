# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/seed-rolling"
require_relative "../scripts/publish-current"
require_relative "../scripts/nix-benchmark"

class BenchmarkBaselineTest < Minitest::Test
  def test_seed_plan_groups_every_project_and_keeps_rolling_cohorts_explicit
    BenchmarkCadence.stub(:verify_cli, nil) do
      seed = RollingSeed.plan
      replay = RollingSeed.plan(observation: "replay")
      assert_equal 22, seed.fetch("runs").length
      assert_equal seed.fetch("runs").map { |run| run.fetch("workflow") }, replay.fetch("runs").map { |run| run.fetch("workflow") }
      seed.fetch("runs").flat_map { |run| ProjectRuns.expand(run) }.each do |run|
        inputs = run.fetch("inputs")
        assert_equal "seed", inputs.fetch("observation")
        if run.fetch("workflow") == "zed-zed-cargo-rolling-auto.yml"
          assert_equal "0", inputs.fetch("source_distance")
        else
          assert_includes inputs.fetch("cache_scope"), seed.fetch("baseline_id")
        end
        assert_equal inputs["base_sha"], inputs["head_sha"] if inputs["base_sha"]
      end
      obs = seed.fetch("runs").find { |run| run.fetch("workflow") == "obs-rolling-benchmark.yml" }
      assert_equal "all", obs.dig("inputs", "cache_tool")
      assert_equal %w[ccache xcode], obs.fetch("selections").map { |run| run.dig("inputs", "cache_tool") }
    end
  end

  def test_pre_reset_outcomes_cannot_restore_the_discarded_feed
    Dir.mktmpdir do |directory|
      %w[daily weekly rolling].each do |cadence|
        BenchmarkCases.write_json(File.join(directory, "benchmark-outcomes-#{cadence}.json"),
          {"collected_at" => "2026-10-06T00:00:00Z", "baseline_id" => "discarded", "records" => []})
      end
      error = assert_raises(BenchmarkCases::Error) { PublishCurrent.build(directory) }
      assert_includes error.message, "discarded baseline"
    end
  end

  def test_baseline_cutoff_includes_only_runs_created_after_reset
    baseline = {"started_at" => "2026-10-06T13:00:00Z"}
    refute BenchmarkBaseline.current?("2026-10-06T12:59:59Z", baseline)
    assert BenchmarkBaseline.current?("2026-10-06T13:00:00Z", baseline)
  end

  def test_nix_seed_cannot_substitute_a_preexisting_output
    BenchmarkPlan.stub(:command, %w[nix build]) do
      previous = ENV["BENCHMARK_OBSERVATION"]
      ENV["BENCHMARK_OBSERVATION"] = "seed"
      assert_equal %w[nix build --option substitute false], NixBenchmark.build_command(phase: "commit", provider: "cachix", cache_name: "benchmark")
    ensure
      ENV["BENCHMARK_OBSERVATION"] = previous
    end
  end
end
