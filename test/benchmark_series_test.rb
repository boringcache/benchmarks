# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/benchmark-series"
require_relative "../scripts/benchmark-evidence"
require_relative "../scripts/collect-series"

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

  def evidence(run_id: 1, conclusion: "success", logs: "Build and cleanup completed\n", repository: BenchmarkCases::REPOSITORY, no_jobs: false)
    directory = File.join(@root, "evidence-#{run_id}")
    FileUtils.mkdir_p(File.join(directory, "attempts", "1"))
    run = {"id" => run_id, "head_sha" => "a" * 40, "run_attempt" => 1, "status" => "completed", "conclusion" => conclusion}
    jobs = no_jobs ? [] : [{"id" => 10, "name" => "Build", "conclusion" => conclusion}]
    manifest = {"repository" => repository, "run_id" => run_id, "run_url" => "https://github.com/#{repository}/actions/runs/#{run_id}",
      "source_sha" => "a" * 40, "state" => "complete", "gaps" => [], "attempts" => [{"attempt" => 1, "job_ids" => jobs.map { |job| job.fetch("id") }}], "artifacts" => [], "files" => {}}
    BenchmarkEvidence.retain_json(directory, "run.json", run, manifest)
    BenchmarkEvidence.retain_json(directory, "attempts/1/run.json", run, manifest)
    BenchmarkEvidence.retain_json(directory, "attempts/1/jobs.json", {"total_count" => jobs.length, "jobs" => jobs}, manifest)
    BenchmarkEvidence.retain_json(directory, "artifacts.json", {"total_count" => 0, "artifacts" => []}, manifest)
    BenchmarkEvidence.retain_json(directory, "commit.json", {"sha" => "a" * 40}, manifest)
    File.write(File.join(directory, "workflow.yml"), "name: Build\n")
    if no_jobs
      File.binwrite(File.join(directory, "attempts/1/logs.zip"), "PK\x05\x06" + "\x00" * 18)
    else
      File.write(File.join(@root, "log.txt"), logs)
      _stdout, stderr, status = Open3.capture3("zip", "-q", File.join(directory, "attempts/1/logs.zip"), "log.txt", chdir: @root)
      raise stderr unless status.success?
    end
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

  def test_report_shows_observations_and_missing_slots_without_generated_advice
    add(record(seconds: 10.125, storage: 0))
    BenchmarkSeries.report(@directory)
    markdown = File.read(File.join(@directory, "report.md"))
    assert_includes markdown, "| BoringCache | Changed-source build | unmeasured | unmeasured | 10.125 | 0 | provider-api |"
    assert_includes markdown, "Sample 2, Actions Cache, Changed-source build"
    assert_includes markdown, "Missing completion checks: 1"
    assert_includes markdown, "runs/1-boringcache-commit.json"
    refute_match(/claims|qualify|requires review|before publication review/, markdown)
  end

  def test_observation_table_escapes_backslashes_and_pipes_in_storage_sources
    value = record(storage: 100)
    value.fetch("cache")["storage_source"] = "provider\\|api\nsource"
    add(value)
    BenchmarkSeries.report(@directory)
    row = File.readlines(File.join(@directory, "report.md")).find { |line| line.include?("[JSON](runs/1-boringcache-commit.json)") }
    assert_includes row, "provider" + "\\" * 3 + "|api source"
  end

  def phase_export(values, artifact_name: nil, filenames: nil, extra_files: {})
    directory = evidence
    manifest = JSON.parse(File.read(File.join(directory, "manifest.json")))
    FileUtils.mkdir_p(File.join(directory, "artifacts"))
    values.each_with_index do |value, index|
      id = index + 1
      name = filenames ? filenames.fetch(index) : "phase-#{id}.json"
      FileUtils.mkdir_p(File.dirname(File.join(@root, name)))
      File.write(File.join(@root, name), JSON.generate(value))
      relative = "artifacts/#{id}.zip"
      path = File.join(directory, relative)
      files = [name]
      if index.zero?
        extra_files.each do |filename, content|
          FileUtils.mkdir_p(File.dirname(File.join(@root, filename)))
          File.write(File.join(@root, filename), JSON.generate(content))
          files << filename
        end
      end
      _output, error, status = Open3.capture3("zip", "-q", path, *files, chdir: @root)
      raise error unless status.success?
      manifest["artifacts"] << {"id" => id, "name" => artifact_name || "phase-#{id}"}
      manifest["files"][relative] = {"bytes" => File.size(path), "sha256" => Digest::SHA256.file(path).hexdigest}
    end
    BenchmarkEvidence.retain_json(directory, "artifacts.json", {"total_count" => values.length, "artifacts" => manifest["artifacts"]}, manifest)
    File.write(File.join(directory, "manifest.json"), JSON.generate(manifest))
    FileUtils.mkdir_p(File.join(@directory, "dispatches"))
    BenchmarkSeries.write_json(File.join(@directory, "dispatches", "1-build.json"),
      {"run_id" => 1, "repository" => BenchmarkCases::REPOSITORY, "case_id" => "example", "inputs" => {"series_id" => "screening", "sample" => "1"}})
    directory
  end

  def test_collects_original_phase_artifacts_and_can_resume_without_overwriting
    value = record
    directory = phase_export([value, record(provider: "actions-cache"), value])
    result = CollectSeries.call(@directory, evidence_directory: directory, sample: 1)
    assert_equal 2, result["records"]
    assert_equal "success", result.dig("completion", "status")
    assert_equal value, JSON.parse(File.read(File.join(@directory, "runs", "1-boringcache-commit.json")))
    assert_equal result, CollectSeries.call(@directory, evidence_directory: directory, sample: 1)
    assert File.file?(File.join(@directory, "report.json"))
  end

  def test_collection_preflights_conflicting_records_before_writing_any_observation
    directory = phase_export([record, record(seconds: 99)])
    assert_raises(BenchmarkSeries::Error) { CollectSeries.call(@directory, evidence_directory: directory, sample: 1) }
    assert_empty Dir[File.join(@directory, "runs", "*.json")]
  end

  def test_collects_canonical_records_from_docker_proof_artifacts
    @directory = File.join(@root, "fresh-series")
    BenchmarkSeries.create(@case, directory: @directory, series: "screening", lane: "fresh", variant: "release")
    values = %w[cold warm].map { |phase| record.merge("lane" => "fresh", "phase" => phase) }
    directory = phase_export(values, artifact_name: "proof-example-linux-amd64",
      filenames: %w[example-boringcache-release-fresh-cold.json example-boringcache-release-fresh-warm.json])
    assert_equal 2, CollectSeries.call(@directory, evidence_directory: directory, sample: 1)["records"]
    values.each do |value|
      assert_equal value, JSON.parse(File.read(File.join(@directory, "runs", "1-boringcache-#{value.fetch('phase')}.json")))
    end
  end

  def test_collects_canonical_records_and_ignores_product_json_in_mixed_bundles
    value = record
    directory = phase_export([value], artifact_name: "deno-cargo-product-head",
      filenames: ["home/runner/work/example/benchmark-results/example-boringcache-release-rolling-commit.json"],
      extra_files: {"tmp/deno-head-primary-action.json" => {"phases" => {"restore" => {}}}})
    result = CollectSeries.call(@directory, evidence_directory: directory, sample: 1)
    assert_equal 1, result["records"]
    assert_equal value, JSON.parse(File.read(File.join(@directory, "runs", "1-boringcache-commit.json")))
  end

  def test_proof_bundle_records_still_require_matching_case_and_dispatch
    directory = phase_export([record.merge("github" => {"run_id" => "2"})], artifact_name: "proof-example-publish-linux-amd64",
      filenames: ["example-boringcache-release-rolling-commit.json"])
    assert_raises(BenchmarkSeries::Error) { CollectSeries.call(@directory, evidence_directory: directory, sample: 1) }
    assert_empty Dir[File.join(@directory, "runs", "*.json")]
  end

  def test_collection_requires_the_original_dispatch_and_matching_run
    directory = phase_export([record.merge("github" => {"run_id" => "2"})])
    assert_raises(BenchmarkSeries::Error) { CollectSeries.call(@directory, evidence_directory: directory, sample: 1) }
    FileUtils.rm(File.join(@directory, "dispatches", "1-build.json"))
    assert_raises(BenchmarkSeries::Error) { CollectSeries.call(@directory, evidence_directory: directory, sample: 1) }
    assert_empty Dir[File.join(@directory, "runs", "*.json")]
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

  def test_complete_correctness_proof_does_not_qualify_a_provider_comparison
    @case["comparison"].merge!("providers" => ["boringcache"], "primary_metric" => "correctness")
    @directory = File.join(@root, "correctness")
    BenchmarkSeries.create(@case, directory: @directory, series: "screening", lane: "fresh", variant: "release")
    [1, 2].each do |sample|
      %w[cold warm].each { |phase| add(record(sample: sample).merge("phase" => phase, "lane" => "fresh", "timing" => {})) }
      BenchmarkSeries.finish(@directory, evidence_directory: evidence(run_id: sample), sample: sample)
    end
    result = BenchmarkSeries.report(@directory)
    assert result["complete"]
    assert result["execution_verified"]
    refute result["valid_for_comparison"]
    assert result["summaries"].all? { |row| row["measurement"].nil? }
    refute_includes File.read(File.join(@directory, "report.md")), "Median correctness"
  end

  def test_methodology_review_keeps_complete_observations_but_blocks_comparative_claims
    @directory = File.join(@root, "reviewed")
    plan = BenchmarkSeries.create(@case, directory: @directory, series: "screening", lane: "fresh", variant: "release")
    [1, 2].each do |sample|
      %w[cold warm].each do |phase|
        %w[boringcache actions-cache].each { |provider| add(record(sample: sample, provider: provider).merge("phase" => phase, "lane" => "fresh")) }
      end
      BenchmarkSeries.finish(@directory, evidence_directory: evidence(run_id: sample), sample: sample)
    end
    assert BenchmarkSeries.report(@directory)["valid_for_comparison"]
    review = {"schema_version" => 1, "plan_sha256" => plan.fetch("plan_sha256"),
      "issues" => ["Setup timing includes dependency installation"], "evidence_links" => ["https://example.org/evidence"]}
    File.write(File.join(@directory, "methodology-review.json"), JSON.generate(review))
    result = BenchmarkSeries.report(@directory)
    assert result["complete"]
    assert result["execution_verified"]
    refute result["valid_for_comparison"]
    assert_equal 8, result["records"].length
    assert_equal [], result["exclusions"]
    assert_equal review["issues"], result["methodology_issues"]
    assert_includes File.read(File.join(@directory, "report.md")), review["issues"].first
  end

  def test_rejects_methodology_reviews_for_another_plan_or_without_evidence
    plan = BenchmarkSeries.load(@directory)
    review = {"schema_version" => 1, "plan_sha256" => "0" * 64,
      "issues" => ["Timing issue"], "evidence_links" => ["https://example.org/evidence"]}
    path = File.join(@directory, "methodology-review.json")
    File.write(path, JSON.generate(review))
    assert_raises(BenchmarkSeries::Error) { BenchmarkSeries.report(@directory) }
    review["plan_sha256"] = plan.fetch("plan_sha256")
    review["evidence_links"] = []
    File.write(path, JSON.generate(review))
    assert_raises(BenchmarkSeries::Error) { BenchmarkSeries.report(@directory) }
  end

  def test_storage_comparison_uses_provider_bytes_for_the_primary_measurement
    @case["comparison"]["primary_metric"] = "storage_bytes"
    @directory = File.join(@root, "storage")
    BenchmarkSeries.create(@case, directory: @directory, series: "screening", lane: "rolling", variant: "release")
    add(record(storage: 100))
    add(record(sample: 2, storage: 300))
    result = BenchmarkSeries.report(@directory)
    assert_equal({"median" => 200.0, "min" => 100, "max" => 300}, result["summaries"].first["measurement"])
    assert_includes File.read(File.join(@directory, "report.md")), "Median storage (bytes)"
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
    assert_includes result["methodology_issues"].first, "Rolling seed and changed-source sequence are unverified."
    assert_equal 4, result["records"].length
    assert_includes File.read(File.join(@directory, "report.md")), "Rolling seed and changed-source sequence are unverified."
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

  def test_cancellation_before_jobs_start_is_retained_without_measurements
    result = BenchmarkSeries.finish(@directory, evidence_directory: evidence(conclusion: "cancelled", no_jobs: true), sample: 1)
    assert_equal "cancelled", result["github_conclusion"]
    assert_equal "failed", result["status"]
    assert_includes result["errors"], "Workflow concluded cancelled"
    report = BenchmarkSeries.report(@directory)
    assert_empty report["records"]
    refute report["valid_for_comparison"]
    assert_equal 1, report["failed_completions"].length
  end
end
