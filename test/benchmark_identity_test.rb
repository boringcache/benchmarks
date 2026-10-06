# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../scripts/benchmark-identity"
require_relative "../scripts/benchmark-cadence"
require_relative "../scripts/cadence-dispatch"

class BenchmarkIdentityTest < Minitest::Test
  def test_branch_advancement_rejects_the_original_plan_before_preparation
    item = BenchmarkCases.load_case("hugo-go")
    Dir.mktmpdir do |root|
      BenchmarkCases.command("git", "init", root)
      commit = -> { BenchmarkCases.command("git", "-c", "user.name=Test", "-c", "user.email=test@example.com", "-c", "commit.gpgsign=false", "commit", "--allow-empty", "-m", "Test snapshot", chdir: root) }
      commit.call
      identity = {"harness_sha" => BenchmarkCases.command("git", "rev-parse", "HEAD", chdir: root).strip,
        "case_id" => item.fetch("id"), "definition_sha256" => "definition"}
      BenchmarkCases.stub(:definition_sha256, "definition") do
        assert_equal identity, BenchmarkIdentity.verify(item, JSON.generate(identity), root: root)
        commit.call
        error = assert_raises(BenchmarkCases::Error) { BenchmarkIdentity.verify(item, JSON.generate(identity), root: root) }
        assert_includes error.message, "Harness commit differs"
      end
    end
  end

  def test_changed_definition_is_rejected_at_the_same_commit
    item = BenchmarkCases.load_case("hugo-go")
    identity = {"harness_sha" => BenchmarkCases.command("git", "rev-parse", "HEAD", chdir: BenchmarkCases::ROOT).strip,
      "case_id" => item.fetch("id"), "definition_sha256" => "wrong"}
    assert_raises(BenchmarkCases::Error) { BenchmarkIdentity.verify(item, JSON.generate(identity)) }
    assert_nil BenchmarkIdentity.verify(item, "")
    ["[]", "null", '{"harness_sha": null}'].each do |invalid|
      assert_raises(BenchmarkCases::Error) { BenchmarkIdentity.verify(item, invalid) }
    end
  end

  def test_scheduled_suite_freezes_existing_series_contract_and_shares_obs_provider_series
    runs = NightlyCanaries::Runner.new.targets(BenchmarkCadence.fresh_targets).map do |repository, workflow, inputs|
      {"repository" => repository, "workflow" => workflow, "inputs" => inputs}
    end
    command = ->(*args, **) { args.include?("rev-parse") ? "a" * 40 : "" }
    BenchmarkCases.stub(:command, command) do
      BenchmarkCadence.freeze_runs("v1.40.0", runs, series_prefix: "cadence-test")
    end
    runs.each do |run|
      series = run.fetch("series")
      assert_equal BenchmarkSeries.digest(series), series.fetch("plan_sha256")
      assert_equal 1, series.fetch("sample_count")
      assert_equal "v1.40.0", series.dig("workflow_inputs", "cli_version")
      assert_equal series.fetch("series_id"), run.dig("inputs", "series_id")
      assert_equal series.fetch("definition_sha256"), JSON.parse(run.dig("inputs", "expected_identity")).fetch("definition_sha256")
      workflow = YAML.safe_load_file(File.join(BenchmarkCases::ROOT, ".github/workflows", run.fetch("workflow")), aliases: true)
      assert workflow.fetch("on").fetch("workflow_dispatch").fetch("inputs").key?("expected_identity")
      assert_equal "${{ inputs.expected_identity }}", workflow.dig("env", "BENCHMARK_EXPECTED_IDENTITY")
    end
    obs = runs.select { |run| run.dig("series", "case_id") == "obs-studio" }
    assert_equal 2, obs.map { |run| run.fetch("series") }.uniq.length
    assert obs.all? { |run| run.dig("series", "phases") == %w[cold commit] }
    record = {"state" => "planned", "cli_version" => "v1.40.0", "channel" => "stable", "ref" => "main", "runs" => runs}
    assert_equal 31, CadenceDispatch.matrix(record).fetch("include").length
    runs.each { |run| run["state"] = "planned" }
    Dir.mktmpdir do |directory|
      CadenceDispatch.materialize(record, directory: directory)
      first = runs.first.fetch("series")
      path = File.join(directory, first.fetch("case_id"), first.fetch("series_id"))
      assert_equal first, BenchmarkSeries.load(path)
      assert File.file?(File.join(path, "report.json"))
      assert_equal 29, Dir[File.join(directory, "*/*/series.json")].length
    end
    runs.first.fetch("inputs")["sample"] = "2"
    assert_raises(CadenceDispatch::Error) { CadenceDispatch.matrix(record) }
  end
end
