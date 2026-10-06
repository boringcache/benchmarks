# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/nightly-canaries"

class NightlyCanariesTest < Minitest::Test
  VERSION = "vcli-canary-0123456789ab"
  BENCHMARK = {"source_repo" => "boringcache/benchmark-example", "fresh_workflow" => "fresh.yml"}

  class FakeRunner < NightlyCanaries::Runner
    attr_reader :requests, :receipt_requests
    attr_accessor :releases, :failure, :conclusion, :parents, :record, :receipt_error

    def initialize
      @requests = []
      @receipt_requests = []
      @parents = []
      @releases = [{"tag_name" => VERSION, "prerelease" => true, "draft" => false,
                    "published_at" => "2026-09-30T01:00:00Z",
                    "assets" => %w[SHA256SUMS boringcache-linux-amd64 boringcache-linux-arm64 boringcache-macos-universal boringcache-windows-amd64.exe].map { |name| {"name" => name} }}]
      @conclusion = "success"
    end

    def api(path, body: nil)
      @requests << {path: path, body: body}
      return @releases if path.include?("releases?")
      return @releases.first if path.include?("releases/tags/")
      return {"workflow_runs" => @parents} if path.include?("canary.yml/runs?") || path.include?("weekly-fresh.yml/runs?")
      if path.include?("/actions/runs/")
        return {"head_sha" => "a" * 40, "status" => @conclusion ? "completed" : "in_progress", "conclusion" => @conclusion}
      end
      return {"state" => "active"} unless body
      raise NightlyCanaries::Error, "dispatch unavailable" if @failure && path.include?(@failure)
      {"workflow_run_id" => @requests.count { |request| request[:body] }}
    end

    def receipt(repository, run_id)
      @receipt_requests << [repository, run_id]
      raise NightlyCanaries::Error, "Receipt missing" if @receipt_error
      @record
    end
  end

  def setup
    @directory = Dir.mktmpdir
    @output = File.join(@directory, "receipt.json")
    @summary = File.join(@directory, "summary.md")
    @runner = FakeRunner.new
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def dispatch(**options)
    @runner.dispatch(repository: BENCHMARK.fetch("source_repo"), output: @output, summary: @summary, benchmarks: [BENCHMARK, BENCHMARK], **options)
  end

  def test_dispatches_each_existing_workflow_once_with_the_exact_canary
    record = dispatch
    posts = @runner.requests.select { |request| request[:body] }
    assert_equal 1, posts.length
    assert_equal({"cli_version" => VERSION}, posts.first[:body]["inputs"])
    assert_equal "main", posts.first[:body]["ref"]
    assert_equal "requested", record["state"]
    assert_equal 1, JSON.parse(File.read(@output))["runs"].first["id"]
    assert_includes File.read(@summary), "/actions/runs/1"
  end

  def test_dry_run_validates_without_dispatching
    assert_equal "planned", dispatch(dry_run: true)["state"]
    assert_empty @runner.requests.select { |request| request[:body] }
  end

  def test_shared_workflow_dispatches_each_case_once_and_retains_its_selector
    first = {"source_repo" => "boringcache/benchmarks", "fresh_workflow" => "native-fresh-benchmark.yml", "case_id" => "hugo-go"}
    second = first.merge("case_id" => "storybook")
    record = @runner.dispatch(repository: "boringcache/benchmarks", output: @output, benchmarks: [first, first, second])
    posts = @runner.requests.select { |request| request[:body] }
    assert_equal 2, posts.length
    assert_equal %w[hugo-go storybook], posts.map { |request| request[:body].dig("inputs", "case_id") }
    assert_equal %w[hugo-go storybook], record["runs"].map { |run| run.dig("inputs", "case_id") }
    assert posts.all? { |request| request[:body].dig("inputs", "cli_version") == VERSION }
  end

  def test_shared_workflow_keeps_distinct_reviewed_variants_in_requests_and_receipts
    first = {"source_repo" => "boringcache/benchmarks", "fresh_workflow" => "native-fresh-benchmark.yml", "case_id" => "n8n", "fresh_inputs" => {"variant" => "turbo"}}
    second = first.merge("fresh_inputs" => {"variant" => "docker"})
    record = @runner.dispatch(repository: "boringcache/benchmarks", output: @output, summary: @summary, benchmarks: [first, first, second])
    posts = @runner.requests.select { |request| request[:body] }
    assert_equal 2, posts.length
    assert_equal %w[turbo docker], posts.map { |request| request[:body].dig("inputs", "variant") }
    assert_equal %w[turbo docker], record["runs"].map { |run| run.dig("inputs", "variant") }
    assert_includes File.read(@summary), "native-fresh-benchmark.yml n8n turbo"
    assert_includes File.read(@summary), "native-fresh-benchmark.yml n8n docker"
  end

  def test_invalid_workload_selectors_fail_before_any_network_or_build_request
    item = {"source_repo" => "boringcache/benchmarks", "fresh_workflow" => "native-fresh-benchmark.yml", "case_id" => "n8n"}
    [{"case_id" => "another-case"}, {"variant" => true}, {"cli_version" => VERSION}].each do |inputs|
      assert_raises(NightlyCanaries::Error) { @runner.dispatch(repository: "boringcache/benchmarks", output: @output, benchmarks: [item.merge("fresh_inputs" => inputs)]) }
    end
    assert_empty @runner.requests
  end

  def test_incomplete_latest_canary_does_not_fall_back_to_an_older_one
    @runner.releases << @runner.releases.first.merge("tag_name" => "vcli-canary-abcdef012345", "published_at" => "2026-09-30T02:00:00Z", "assets" => [])
    assert_raises(NightlyCanaries::Error) { dispatch }
    assert_empty @runner.requests.select { |request| request[:body] }
  end

  def test_manual_version_must_also_be_a_complete_published_canary
    @runner.releases.first["draft"] = true
    assert_raises(NightlyCanaries::Error) { dispatch(version: VERSION) }
    assert_empty @runner.requests.select { |request| request[:body] }
  end

  def test_retains_completed_dispatches_when_a_later_request_fails
    @runner.failure = "second.yml"
    second = BENCHMARK.merge("fresh_workflow" => "second.yml")
    assert_raises(NightlyCanaries::Error) do
      @runner.dispatch(repository: BENCHMARK.fetch("source_repo"), output: @output, summary: @summary, benchmarks: [BENCHMARK, second])
    end
    record = JSON.parse(File.read(@output))
    assert_equal "dispatch-failed", record["state"]
    assert_equal 1, record["runs"].first["id"]
    assert_equal "request-unknown", record["runs"].last["state"]
  end

  def test_checks_the_recorded_run_and_reports_failure
    record = dispatch
    @runner.conclusion = "failure"
    refute @runner.check(record, summary: @summary)
    assert_includes File.read(@summary), "**failure**"
    assert_equal "a" * 40, record["runs"].first["source_sha"]
    assert @runner.requests.any? { |request| request[:path].end_with?("/actions/runs/1") }
  end

  def test_pending_work_is_reported_as_pending
    record = dispatch
    @runner.conclusion = nil
    assert @runner.check(record, summary: @summary)
    assert_includes File.read(@summary), "**in_progress**"
    refute_includes File.read(@summary), "**success**"
  end

  def test_dispatch_is_limited_to_the_selected_repository
    other = BENCHMARK.merge("source_repo" => "boringcache/benchmark-other")
    @runner.dispatch(repository: BENCHMARK.fetch("source_repo"), output: @output, summary: @summary,
      benchmarks: [BENCHMARK, other])
    refute @runner.requests.any? { |request| request[:path].include?("benchmark-other") }
  end

  def test_unknown_or_archived_repositories_cannot_dispatch
    [[], [BENCHMARK.merge("archived" => true)]].each do |benchmarks|
      assert_raises(NightlyCanaries::Error) do
        @runner.dispatch(repository: BENCHMARK.fetch("source_repo"), output: @output, summary: @summary,
          benchmarks: benchmarks)
      end
    end
    assert_empty @runner.requests
  end

  def prepare_collection
    @runner.record = dispatch
    @runner.parents = [
      {"id" => 21, "display_title" => "CLI canary dispatch", "created_at" => "2026-09-30T02:17:00Z", "status" => "completed", "conclusion" => "success"},
      {"id" => 20, "display_title" => "CLI canary dispatch", "created_at" => "2026-09-29T02:17:00Z", "status" => "completed", "conclusion" => "success"}
    ]
  end

  def collect
    @runner.collect(summary: @summary, benchmarks: [BENCHMARK], now: Time.utc(2026, 9, 30, 12))
  end

  def test_collects_exact_child_ids_from_the_latest_dispatch_even_when_the_child_failed
    prepare_collection
    @runner.conclusion = "failure"
    refute collect
    assert_equal [[BENCHMARK.fetch("source_repo"), 21]], @runner.receipt_requests
    assert_includes File.read(@summary), "**failure**"
    assert_includes File.read(@summary), "/actions/runs/1"
  end

  def test_weekly_collection_uses_its_own_dispatch_and_retains_structured_outcomes
    prepare_collection
    @runner.record["cli_version"] = "v1.40.0"
    @runner.record["channel"] = "stable"
    assert @runner.collect(summary: @summary, output: @output, channel: "stable", benchmarks: [BENCHMARK], now: Time.utc(2026, 10, 5))
    assert @runner.requests.any? { |request| request[:path].include?("weekly-fresh.yml/runs?") }
    retained = JSON.parse(File.read(@output))
    assert_equal true, retained.fetch("passed")
    assert_equal "success", retained.dig("repositories", 0, "dispatch", "runs", 0, "state")
    assert_includes File.read(@summary), "CLI stable benchmark results"
  end

  def test_missing_latest_receipt_does_not_fall_back_to_an_older_success
    prepare_collection
    @runner.receipt_error = true
    refute collect
    assert_equal [[BENCHMARK.fetch("source_repo"), 21]], @runner.receipt_requests
    assert_includes File.read(@summary), "Receipt missing"
  end

  def test_receipt_cannot_report_another_repository
    prepare_collection
    @runner.record["runs"].first["repository"] = "boringcache/benchmark-other"
    refute collect
    refute @runner.requests.any? { |request| request[:path].include?("benchmark-other") }
  end

  def test_failed_dispatch_is_not_hidden_by_a_successful_child
    prepare_collection
    @runner.parents.first["conclusion"] = "failure"
    refute collect
  end

  def test_running_dispatch_does_not_require_a_receipt_yet
    prepare_collection
    @runner.parents.first["status"] = "in_progress"
    assert collect
    assert_empty @runner.receipt_requests
    assert_includes File.read(@summary), "in_progress"
  end

  def test_before_first_dispatch_reports_that_no_run_has_been_observed
    refute collect
    assert_includes File.read(@summary), "No canary dispatch has been observed yet"
    refute_includes File.read(@summary), "**success**"
  end

  def test_old_success_does_not_hide_a_missed_nightly_dispatch
    prepare_collection
    refute @runner.collect(summary: @summary, benchmarks: [BENCHMARK], now: Time.utc(2026, 10, 2))
    assert_includes File.read(@summary), "more than 36 hours old"
  end

  def test_receipt_run_ids_must_be_positive_integers
    prepare_collection
    @runner.record["runs"].first["id"] = "1/jobs"
    refute collect
    assert_includes File.read(@summary), "invalid run ID"
    refute @runner.requests.any? { |request| request[:path].include?("1/jobs") }
  end

  def test_collector_skips_archived_benchmarks
    assert @runner.collect(summary: @summary, benchmarks: [BENCHMARK.merge("archived" => true)])
    assert_empty @runner.requests
  end

  def test_collects_the_active_historical_canary_until_cutover
    prepare_collection
    item = BENCHMARK.merge("source_repo" => "boringcache/benchmarks", "case_id" => "example",
      "fresh_workflow" => "native-fresh-benchmark.yml", "fresh_inputs" => {"variant" => "layers"},
      "historical_source_repo" => BENCHMARK.fetch("source_repo"), "historical_fresh_workflow" => "fresh.yml",
      "canary_location" => "historical")
    assert @runner.collect(summary: @summary, benchmarks: [item], now: Time.utc(2026, 9, 30, 12))
    assert_equal [[BENCHMARK.fetch("source_repo"), 21]], @runner.receipt_requests
    refute @runner.requests.any? { |request| request[:path].start_with?("repos/boringcache/benchmarks/") }

    @runner.conclusion = "failure"
    refute @runner.collect(summary: @summary, benchmarks: [item], now: Time.utc(2026, 9, 30, 12))
    assert_includes File.read(@summary), "**failure**"
  end

  def test_canary_cutover_requires_a_known_location
    assert_raises(NightlyCanaries::Error) do
      @runner.collect(summary: @summary, benchmarks: [BENCHMARK.merge("canary_location" => "typo")])
    end
    assert_empty @runner.requests
  end
end
