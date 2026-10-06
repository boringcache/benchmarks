# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/fresh-report"
require_relative "../scripts/nightly-canaries"
require "minitest/mock"

class FreshReportTest < Minitest::Test
  def jobs(conclusions)
    FreshReport.expected("hugo-go").zip(conclusions).map do |slot, conclusion|
      {"name" => slot.fetch("job_name"), "status" => "completed", "conclusion" => conclusion,
        "steps" => conclusion == "failure" ? [{"name" => "Build Hugo", "conclusion" => "failure"}] : []}
    end
  end

  def test_failed_cold_provider_keeps_completed_observation_and_skipped_warm_phases
    record = {"strategy" => "actions-cache", "phase" => "cold", "verification" => {"passed" => true}, "timing" => {"build_seconds" => 12}}
    outcome = {"strategy" => "boringcache", "phase" => "cold", "verification" => false, "timing" => {"build_seconds" => 5}}
    values = FreshReport.reconcile(FreshReport.expected("hugo-go"), jobs: jobs(%w[success skipped failure skipped]),
      records: [record], outcomes: [outcome], run_url: "https://example.com/run")
    assert_equal %w[succeeded skipped failed skipped], values.map { |value| value.fetch("state") }
    assert_equal 12, values[0].dig("timing", "build_seconds")
    assert_equal 5, values[2].dig("timing", "build_seconds")
    assert_equal false, values[2]["verification"]
    assert_equal [{"step" => "Build Hugo", "conclusion" => "failure"}], values[2]["errors"]
    assert_empty values[1]["timing"]
    assert_nil values[2]["storage_bytes"]
  end

  def test_post_step_failure_overrides_an_earlier_success_record
    record = {"strategy" => "actions-cache", "phase" => "cold", "verification" => {"passed" => true}}
    values = FreshReport.reconcile(FreshReport.expected("hugo-go"), jobs: jobs(%w[failure skipped cancelled skipped]), records: [record], run_url: "https://example.com/run")
    assert_equal "failed", values.first.fetch("state")
    assert_equal true, values.first.fetch("verification")
    assert_equal "cancelled", values[2].fetch("state")
  end

  def test_skipped_warm_matrix_does_not_require_expanded_provider_jobs
    observed = jobs(%w[failure skipped failure skipped]).reject { |job| job["conclusion"] == "skipped" }
    observed << {"name" => "warm", "status" => "completed", "conclusion" => "skipped"}
    values = FreshReport.reconcile(FreshReport.expected("hugo-go"), jobs: observed, run_url: "https://example.com/run")
    assert_equal %w[failed skipped failed skipped], values.map { |value| value.fetch("state") }
  end

  def test_missing_jobs_or_artifacts_do_not_acquire_measurements
    [[], jobs(%w[success success success success])].each do |observed_jobs|
      values = FreshReport.reconcile(FreshReport.expected("hugo-go"), jobs: observed_jobs, run_url: "https://example.com/run")
      assert values.all? { |value| value["state"] == "missing" && value["timing"].empty? && value["verification"] == "unrecorded" }
    end
  end

  def test_report_with_no_artifacts_still_writes_all_expected_observations
    Dir.mktmpdir do |directory|
      manifest = FreshReport.report(BenchmarkCases.load_case("hugo-go"), input_dir: File.join(directory, "missing"),
        output_dir: directory, jobs: jobs(%w[failure skipped failure skipped]), run_url: "https://example.com/run")
      assert_equal 4, manifest.fetch("observations").length
      assert File.file?(File.join(directory, "run-manifest.json"))
      report = File.read(File.join(directory, "run-report.md"))
      assert_includes report, "unmeasured"
      refute_includes report, "0s"
      refute File.exist?(File.join(directory, "hugo-go-boringcache-fresh.json"))
    end
  end

  def test_parent_reconciles_cancellation_without_a_child_report
    runner = NightlyCanaries::Runner.new
    run = {"id" => 42, "repository" => "boringcache/benchmarks", "url" => "https://example.com/run",
      "workflow" => "native-fresh-benchmark.yml", "harness_sha" => "a" * 40, "series" => {"case_id" => "hugo-go"}}
    record = {"state" => "requested", "runs" => [run]}
    api = ->(*) { {"head_sha" => "a" * 40, "status" => "completed", "conclusion" => "cancelled", "run_attempt" => 1} }
    runner.stub(:api, api) do
      runner.stub(:phase_evidence, []) do
        runner.stub(:jobs, jobs(%w[cancelled skipped cancelled skipped])) do
          refute runner.check(record, summary: nil)
        end
      end
    end
    assert_equal "cancelled", run.fetch("state")
    assert_equal %w[cancelled skipped cancelled skipped], run.fetch("observations").map { |value| value.fetch("state") }
    assert run.fetch("observations").all? { |value| value.fetch("timing").empty? }
  end

  def test_partial_report_keeps_canonical_measurements_and_names
    item = BenchmarkCases.load_case("hugo-go")
    record = {"schema_version" => 1, "benchmark" => "hugo-go", "strategy" => "actions-cache", "phase" => "cold", "lane" => "fresh",
      "github" => {"run_id" => ENV.fetch("GITHUB_RUN_ID", "42"), "run_attempt" => ENV.fetch("GITHUB_RUN_ATTEMPT", "1")},
      "case" => {"case_id" => "hugo-go"}, "source" => {"repository" => "gohugoio/hugo", "sha" => "a" * 40},
      "cache" => {"storage_bytes" => nil}, "verification" => {"passed" => true},
      "timing" => {"total_seconds" => 15, "build_seconds" => 12, "restore_or_setup_seconds" => 3}}
    Dir.mktmpdir do |directory|
      input = File.join(directory, "input")
      BenchmarkCases.write_json(File.join(input, "cold.json"), record)
      manifest = FreshReport.report(item, input_dir: input, output_dir: directory,
        jobs: jobs(%w[success skipped failure skipped]), run_url: "https://example.com/run")
      assert_equal %w[succeeded skipped failed skipped], manifest.fetch("observations").map { |value| value.fetch("state") }
      lane = JSON.parse(File.read(File.join(directory, "hugo-go-actions-cache-fresh.json")))
      assert_equal 15, lane.dig("runs", "cold_seconds")
      refute File.exist?(File.join(directory, "hugo-go-boringcache-fresh.json"))
    end
  end
end
