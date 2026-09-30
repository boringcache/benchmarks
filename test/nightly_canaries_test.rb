# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/nightly-canaries"

class NightlyCanariesTest < Minitest::Test
  VERSION = "vcli-canary-0123456789ab"
  BENCHMARK = {"source_repo" => "boringcache/benchmark-example", "fresh_workflow" => "fresh.yml"}

  class FakeRunner < NightlyCanaries::Runner
    attr_reader :requests
    attr_accessor :releases, :failure, :conclusion

    def initialize
      @requests = []
      @releases = [{"tag_name" => VERSION, "prerelease" => true, "draft" => false,
                    "published_at" => "2026-09-30T01:00:00Z",
                    "assets" => %w[SHA256SUMS boringcache-linux-amd64 boringcache-linux-arm64 boringcache-macos-universal boringcache-windows-amd64.exe].map { |name| {"name" => name} }}]
      @conclusion = "success"
    end

    def api(path, body: nil)
      @requests << {path: path, body: body}
      return @releases if path.include?("releases?")
      return @releases.first if path.include?("releases/tags/")
      if path.include?("/actions/runs/")
        return {"head_sha" => "a" * 40, "status" => @conclusion ? "completed" : "in_progress", "conclusion" => @conclusion}
      end
      return {"state" => "active"} unless body
      raise NightlyCanaries::Error, "dispatch unavailable" if @failure && path.include?(@failure)
      {"workflow_run_id" => @requests.count { |request| request[:body] }}
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
    @runner.dispatch(output: @output, summary: @summary, benchmarks: [BENCHMARK, BENCHMARK], **options)
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
      @runner.dispatch(output: @output, summary: @summary, benchmarks: [BENCHMARK, second])
    end
    record = JSON.parse(File.read(@output))
    assert_equal "dispatch-failed", record["state"]
    assert_equal 1, record["runs"].first["id"]
    assert_equal "planned", record["runs"].last["state"]
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
end
