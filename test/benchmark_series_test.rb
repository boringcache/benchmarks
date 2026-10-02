# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/benchmark-series"
require_relative "../scripts/benchmark-evidence"

class BenchmarkSeriesTest < Minitest::Test
  def setup
    @root = Dir.mktmpdir("benchmark-series-")
    @directory = File.join(@root, "series")
    @case = {"id" => "example", "verification" => ["Output runs"],
      "source" => {"repository" => "example/upstream", "pins" => [{"revision" => "a" * 40}]},
      "comparison" => {"question" => "Does reuse reduce build time?", "providers" => %w[actions-cache boringcache],
        "primary_metric" => "build_and_reuse_seconds", "sample_count" => 2, "timed_scope" => "Restore and compile"}}
    BenchmarkSeries.create(@case, directory: @directory, series: "screening", lane: "rolling", variant: "release")
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def record(sample: 1, provider: "boringcache", seconds: 10, storage: nil)
    {"series" => {"id" => "screening", "sample" => sample}, "case" => {"case_id" => "example", "definition_sha256" => Digest::SHA256.hexdigest(JSON.generate(@case))},
      "strategy" => provider, "phase" => "commit", "lane" => "rolling", "variant" => "release",
      "source" => {"repository" => "example/upstream", "sha" => "a" * 40},
      "environment" => {"os" => "Linux", "arch" => "X64", "image" => "ubuntu26", "image_version" => "20261001", "machine" => "ubuntu-26.04"},
      "verification" => {"passed" => true, "checks" => ["Output runs"]}, "evidence_links" => ["https://example.org/evidence"],
      "product_refs" => {"cli_version" => "v1.33.0", "action_sha" => "e" * 40},
      "github" => {"run_id" => sample.to_s},
      "timing" => {"comparison_scope" => "Restore and compile", "build_and_reuse_seconds" => seconds, "workflow_seconds" => 9999},
      "cache" => {"storage_bytes" => storage, "storage_source" => storage && "provider-api"}}
  end

  def add(value)
    path = File.join(@root, "record.json")
    File.write(path, JSON.generate(value))
    BenchmarkSeries.record(@directory, path)
  end

  def evidence(run_id: 1, conclusion: "success", logs: "Build and cleanup completed\n", repository: BenchmarkCases::REPOSITORY)
    directory = File.join(@root, "evidence-#{run_id}")
    FileUtils.mkdir_p(File.join(directory, "attempts", "1"))
    run = {"id" => run_id, "head_sha" => "a" * 40, "run_attempt" => 1, "status" => "completed", "conclusion" => conclusion}
    manifest = {"repository" => repository, "run_id" => run_id, "run_url" => "https://github.com/#{repository}/actions/runs/#{run_id}",
      "source_sha" => "a" * 40, "state" => "complete", "gaps" => [], "attempts" => [{"attempt" => 1, "job_ids" => [10]}], "artifacts" => [], "files" => {}}
    BenchmarkEvidence.retain_json(directory, "run.json", run, manifest)
    BenchmarkEvidence.retain_json(directory, "attempts/1/run.json", run, manifest)
    BenchmarkEvidence.retain_json(directory, "attempts/1/jobs.json", {"total_count" => 1, "jobs" => [{"id" => 10, "name" => "Build", "conclusion" => conclusion}]}, manifest)
    BenchmarkEvidence.retain_json(directory, "artifacts.json", {"total_count" => 0, "artifacts" => []}, manifest)
    BenchmarkEvidence.retain_json(directory, "commit.json", {"sha" => "a" * 40}, manifest)
    File.write(File.join(directory, "workflow.yml"), "name: Build\n")
    File.write(File.join(@root, "log.txt"), logs)
    _stdout, stderr, status = Open3.capture3("zip", "-q", File.join(directory, "attempts/1/logs.zip"), "log.txt", chdir: @root)
    raise stderr unless status.success?
    %w[workflow.yml attempts/1/logs.zip].each do |relative|
      path = File.join(directory, relative)
      manifest["files"][relative] = {"bytes" => File.size(path), "sha256" => Digest::SHA256.file(path).hexdigest}
    end
    File.write(File.join(directory, "manifest.json"), JSON.generate(manifest))
    directory
  end

  def test_reports_all_predeclared_samples_and_keeps_slow_measurements
    add(record(seconds: 10, storage: 100))
    add(record(sample: 2, seconds: 900))
    add(record(provider: "actions-cache", seconds: 20, storage: 200))
    add(record(sample: 2, provider: "actions-cache", seconds: 30, storage: 300))
    result = BenchmarkSeries.report(@directory)
    assert result["complete"]
    assert_equal [], result["exclusions"]
    summary = result["summaries"].find { |row| row["provider"] == "boringcache" }
    assert_equal({"median" => 455.0, "min" => 10, "max" => 900}, summary["measurement"])
    assert_equal 100, summary.dig("storage", "median")
    assert_equal 1, summary["storage_measured_count"]
    assert_equal "unreviewed", result["publication"]
  end

  def test_incomplete_series_reports_missing_samples_without_a_complete_claim
    add(record)
    result = BenchmarkSeries.report(@directory)
    refute result["complete"]
    assert_equal 3, result["missing"].length
    assert_nil result["summaries"].first["storage"]
  end

  def test_rejects_mismatched_runner_pair
    add(record)
    other = record(provider: "actions-cache")
    other["environment"]["image_version"] = "different"
    add(other)
    error = assert_raises(BenchmarkSeries::Error) { BenchmarkSeries.report(@directory) }
    assert_includes error.message, "different source, case, variant, or runner environments"
  end

  def test_cannot_replace_a_slow_sample
    add(record(seconds: 900))
    assert_raises(BenchmarkSeries::Error) { add(record(seconds: 9)) }
  end

  def test_requires_correctness_and_declared_measurement_scope
    value = record
    value["verification"]["passed"] = false
    assert_raises(BenchmarkSeries::Error) { add(value) }
    value = record
    value["timing"]["comparison_scope"] = "Whole workflow"
    assert_raises(BenchmarkSeries::Error) { add(value) }
  end

  def test_detects_changed_plan
    path = File.join(@directory, "series.json")
    plan = JSON.parse(File.read(path))
    plan["sample_count"] = 1
    File.write(path, JSON.generate(plan))
    assert_raises(BenchmarkSeries::Error) { BenchmarkSeries.load(@directory) }
  end

  def test_rejects_undeclared_source_and_sample
    value = record(sample: 3)
    assert_raises(BenchmarkSeries::Error) { add(value) }
    value = record
    value["source"]["sha"] = "c" * 40
    assert_raises(BenchmarkSeries::Error) { add(value) }
  end

  def test_binds_records_to_the_frozen_case_and_storage_measurement_source
    value = record
    value["case"]["definition_sha256"] = "b" * 64
    assert_raises(BenchmarkSeries::Error) { add(value) }
    value = record(storage: 100)
    value["cache"].delete("storage_source")
    assert_raises(BenchmarkSeries::Error) { add(value) }
    value = record(storage: -1)
    assert_raises(BenchmarkSeries::Error) { add(value) }
  end

  def test_retains_failed_observations_without_using_their_timings
    value = record(seconds: 1)
    value["status"] = "failed"
    value["error"] = "Compiler exited with status 1"
    value["verification"]["passed"] = false
    add(value)
    result = BenchmarkSeries.report(@directory)
    assert_equal 1, result["failures"].length
    assert_empty result["summaries"]
    refute result["valid_for_comparison"]
    assert_equal 3, result["missing"].length
    assert_raises(BenchmarkSeries::Error) { add(record(seconds: 9)) }
  end

  def test_changed_source_seed_is_distinct_from_identical_source_replay
    @case["source"]["pins"] << {"revision" => "b" * 40}
    @directory = File.join(@root, "changed-source")
    BenchmarkSeries.create(@case, directory: @directory, series: "screening", lane: "fresh", phases: %w[cold commit], variant: "release")
    cold = record
    cold.merge!("phase" => "cold", "lane" => "fresh")
    add(cold)
    add(record)
    error = assert_raises(BenchmarkSeries::Error) { BenchmarkSeries.report(@directory) }
    assert_includes error.message, "reused the seed revision"
  end

  def test_identical_source_replay_cannot_use_a_changed_revision
    @case["source"]["pins"] << {"revision" => "b" * 40}
    @directory = File.join(@root, "replay")
    BenchmarkSeries.create(@case, directory: @directory, series: "screening", lane: "fresh", variant: "release")
    cold = record.merge("phase" => "cold", "lane" => "fresh")
    add(cold)
    warm = record.merge("phase" => "warm", "lane" => "fresh")
    warm["source"]["sha"] = "b" * 40
    add(warm)
    error = assert_raises(BenchmarkSeries::Error) { BenchmarkSeries.report(@directory) }
    assert_includes error.message, "different source revisions"
  end

  def test_cannot_combine_measurements_from_different_product_versions
    add(record)
    other = record(sample: 2)
    other["product_refs"]["cli_version"] = "v1.34.0"
    add(other)
    error = assert_raises(BenchmarkSeries::Error) { BenchmarkSeries.report(@directory) }
    assert_includes error.message, "different CLI or Action versions"
  end

  def test_phase_timings_require_verified_workflow_completion
    @directory = File.join(@root, "replay-completion")
    BenchmarkSeries.create(@case, directory: @directory, series: "screening", lane: "fresh", variant: "release")
    [1, 2].each do |sample|
      %w[boringcache actions-cache].each do |provider|
        %w[cold warm].each { |phase| add(record(sample: sample, provider: provider).merge("phase" => phase, "lane" => "fresh")) }
      end
    end
    refute BenchmarkSeries.report(@directory)["valid_for_comparison"]
    [1, 2].each { |sample| BenchmarkSeries.finish(@directory, evidence_directory: evidence(run_id: sample), sample: sample) }
    assert BenchmarkSeries.report(@directory)["valid_for_comparison"]
    assert_raises(BenchmarkSeries::Error) { BenchmarkSeries.finish(@directory, evidence_directory: File.join(@root, "evidence-1"), sample: 1) }
  end

  def test_completed_rolling_runs_without_seed_lineage_remain_diagnostic
    [1, 2].each do |sample|
      %w[boringcache actions-cache].each { |provider| add(record(sample: sample, provider: provider)) }
      BenchmarkSeries.finish(@directory, evidence_directory: evidence(run_id: sample), sample: sample)
    end
    result = BenchmarkSeries.report(@directory)
    assert result["complete"]
    assert result["execution_verified"]
    refute result["valid_for_comparison"]
    assert_includes result["methodology_issues"].first, "no verified seed and changed-source sequence"
    assert_equal 4, result["records"].length
    assert_includes File.read(File.join(@directory, "report.md")), "retain them as diagnostic"
  end

  def test_green_jobs_with_post_step_warnings_cannot_qualify_a_series
    add(record)
    result = BenchmarkSeries.finish(@directory, evidence_directory: evidence(logs: "##[warning]boringcache/one save failed: empty boolean input\n"), sample: 1)
    assert_equal "success", result["github_conclusion"]
    assert_equal "failed", result["status"]
    assert_includes result["errors"].first, "empty boolean input"
    report = BenchmarkSeries.report(@directory)
    refute report["execution_verified"]
    refute report["valid_for_comparison"]
    assert_equal 1, report["failed_completions"].length
  end

  def test_failed_runs_and_foreign_or_changed_exports_are_not_qualified
    result = BenchmarkSeries.finish(@directory, evidence_directory: evidence(conclusion: "cancelled"), sample: 1)
    assert_equal "failed", result["status"]
    assert_raises(BenchmarkSeries::Error) { BenchmarkSeries.finish(@directory, evidence_directory: evidence(run_id: 2, repository: "other/repository"), sample: 2) }
    path = File.join(@root, "evidence-1", "workflow.yml")
    File.write(path, "changed\n")
    assert_raises(BenchmarkCases::Error) { BenchmarkSeries.finish(@directory, evidence_directory: File.join(@root, "evidence-1"), sample: 1) }
  end
end
