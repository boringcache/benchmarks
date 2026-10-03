# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/benchmark-catalog"

class BenchmarkCatalogTest < Minitest::Test
  def setup
    @root = Dir.mktmpdir("benchmark-catalog-")
    @directory = File.join(@root, "results/example/screening")
    @case = {"id" => "example", "verification" => ["Output runs"],
      "source" => {"repository" => "example/upstream", "pins" => [{"revision" => "a" * 40}]},
      "comparison" => {"question" => "Does reuse reduce build time?", "providers" => %w[actions-cache boringcache],
        "primary_metric" => "build_and_reuse_seconds", "sample_count" => 10, "timed_scope" => "Restore and compile"}}
    BenchmarkCases.write_json(File.join(@root, "cases/example/case.json"), @case)
    @plan = BenchmarkSeries.create(@case, directory: @directory, series: "screening", lane: "fresh", samples: 1)
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def entry
    BenchmarkCatalog.build(root: @root).fetch("series").fetch(0)
  end

  def add(provider:, phase:, seconds:, run_id:)
    value = {"series" => {"id" => "screening", "sample" => 1},
      "case" => {"case_id" => "example", "definition_sha256" => @plan.fetch("definition_sha256")},
      "strategy" => provider, "phase" => phase, "lane" => "fresh", "variant" => nil,
      "source" => {"repository" => "example/upstream", "sha" => "a" * 40},
      "environment" => {"os" => "Linux", "arch" => "X64", "machine" => "ubuntu-24.04", "image" => "ubuntu24", "image_version" => "20261001"},
      "verification" => {"passed" => true, "checks" => ["Output runs"]}, "evidence_links" => ["https://example.org/evidence"],
      "product_refs" => {"cli_version" => "1.33.0", "action_sha" => "e" * 40},
      "github" => {"run_id" => run_id}, "cache" => {"storage_bytes" => nil},
      "timing" => {"comparison_scope" => "Restore and compile", "build_and_reuse_seconds" => seconds}}
    path = File.join(@root, "phase.json")
    BenchmarkCases.write_json(path, value)
    BenchmarkSeries.record(@directory, path)
  end

  def completion(run_id:, status: "success")
    BenchmarkCases.write_json(File.join(@directory, "completions/#{run_id}.json"),
      {"case_id" => "example", "series_id" => "screening", "run_id" => run_id,
        "status" => status, "errors" => status == "success" ? [] : ["Report upload failed"]})
  end

  def test_planned_requested_and_incomplete_states_do_not_claim_execution
    assert_equal "planned", entry.fetch("state")
    refute entry.fetch("execution_verified")
    assert_equal 4, entry.fetch("missing_observations").length
    receipt = {"case_id" => "example", "repository" => BenchmarkCases::REPOSITORY,
      "state" => "requested", "run_id" => 12, "run_url" => "https://github.com/boringcache/benchmarks/actions/runs/12"}
    BenchmarkCases.write_json(File.join(@directory, "dispatches/1.json"), receipt)
    requested = entry
    assert_equal "requested", requested.fetch("state")
    assert_equal ["12"], requested.fetch("runs_without_archives")
    assert_equal receipt, requested.fetch("dispatches").fetch(0)
    add(provider: "boringcache", phase: "cold", seconds: 20, run_id: "12")
    assert_equal "incomplete", entry.fetch("state")
    refute entry.fetch("valid_for_comparison")
    refute File.exist?(File.join(@directory, "report.json"))
  end

  def test_completed_negative_observations_remain_unreviewed_and_reports_are_not_rewritten
    %w[cold warm].each do |phase|
      add(provider: "boringcache", phase: phase, seconds: 100, run_id: "12")
      add(provider: "actions-cache", phase: phase, seconds: 10, run_id: "13")
    end
    completion(run_id: "12")
    completion(run_id: "13")
    expected = BenchmarkSeries.report(@directory)
    before = Dir[File.join(@directory, "**/*")].select { |path| File.file?(path) }.to_h { |path| [path, Digest::SHA256.file(path).hexdigest] }
    result = entry
    assert_equal "completed", result.fetch("state")
    assert result.fetch("valid_for_comparison")
    assert_equal "unreviewed", result.fetch("publication")
    assert_equal 1, result.fetch("sample_count")
    assert_equal 10, result.dig("comparison", "sample_count")
    assert_equal expected.fetch("summaries"), result.fetch("summaries")
    assert_equal "current", result.fetch("report_state")
    assert_equal "results/example/screening/report.json", result.fetch("report_path")
    assert_equal before, before.to_h { |path, _digest| [path, Digest::SHA256.file(path).hexdigest] }
    File.write(File.join(@directory, "report.json"), "{}\n")
    assert_equal "stale", entry.fetch("report_state")
    assert_nil entry.fetch("report_path")
    assert_equal "{}\n", File.read(File.join(@directory, "report.json"))
  end

  def test_failed_completions_and_archive_gaps_remain_visible_without_observations
    completion(run_id: "12", status: "failed")
    archive = {"repository" => BenchmarkCases::REPOSITORY, "run_id" => 12, "inventory_state" => "complete",
      "release_url" => "https://github.com/boringcache/benchmarks/releases/tag/evidence-example",
      "scope" => "Available logs only", "unavailable_workflow_evidence" => ["Original phase JSON was never uploaded"]}
    BenchmarkCases.write_json(File.join(@root, "migration/evidence.json"), {"exports" => [archive]})
    result = entry
    assert_equal "failed", result.fetch("state")
    assert_equal ["Report upload failed"], result.fetch("completions").fetch(0).fetch("errors")
    assert_equal [archive], result.fetch("evidence")
    assert_empty result.fetch("runs_without_archives")
    refute result.fetch("execution_verified")
    refute result.fetch("valid_for_comparison")
    assert_empty result.fetch("summaries")
  end

  def test_invalid_series_remains_in_the_catalog
    @plan["sample_count"] = 99
    BenchmarkCases.write_json(File.join(@directory, "series.json"), @plan)
    result = entry
    assert_equal "invalid", result.fetch("state")
    assert_equal "example", result.fetch("case_id")
    refute result.fetch("valid_for_comparison")
    assert_match(/plan changed/, result.fetch("error"))
  end

  def test_unknown_case_does_not_publish_a_series_summary
    File.delete(File.join(@root, "cases/example/case.json"))
    assert_equal "invalid", entry.fetch("state")
    assert_match(/Unknown case/, entry.fetch("error"))
  end
end
