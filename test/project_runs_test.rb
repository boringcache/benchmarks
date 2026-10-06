# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../scripts/benchmark-cadence"
require_relative "../scripts/project-report"
require_relative "../scripts/rolling-monitor"

class ProjectRunsTest < Minitest::Test
  def selections
    BenchmarkCadence.fresh_targets(case_id: "n8n").map do |target|
      {"repository" => BenchmarkCases::REPOSITORY, "workflow" => target.fetch("fresh_workflow"),
        "inputs" => target.fetch("fresh_inputs").merge("cadence" => "nightly"), "state" => "planned"}
    end
  end

  def test_one_project_request_preserves_every_variant_and_cadence
    grouped = ProjectRuns.group(selections, lane: "fresh")
    assert_equal 1, grouped.length
    assert_equal "project-fresh.yml", grouped.first.fetch("workflow")
    assert_equal "nightly", grouped.first.dig("inputs", "cadence")
    expanded = ProjectRuns.expand(grouped.first.merge("id" => 42, "url" => "https://example.com/run/42"))
    assert_equal %w[distroless docker runners turbo], expanded.map { |run| run.dig("inputs", "variant") }.sort
    assert_equal [42], expanded.map { |run| run.fetch("id") }.uniq
    assert_equal selections.map { |run| run.fetch("inputs") }, expanded.map { |run| run.fetch("inputs") }
  end

  def test_missing_project_phases_remain_visible
    rows = ProjectReport.observations([], selections: selections.map { |run| run.slice("workflow", "inputs") },
      project: "n8n", lane: "fresh", run_url: "https://example.com/run/42")
    assert_equal 16, rows.length
    assert_equal ["missing"], rows.map { |row| row.fetch("state") }.uniq
    assert rows.all? { |row| row["storage_bytes"].nil? }
    assert_includes ProjectReport.markdown(rows, project: "n8n"), "unmeasured"
  end

  def test_grouped_rolling_success_without_phases_is_not_accepted
    item = BenchmarkCases.load_case("n8n")
    runs = BenchmarkCadence.rolling_targets(case_id: "n8n").map { |plan| plan.slice("repository", "workflow", "inputs") }
    run = ProjectRuns.group(runs, lane: "rolling").first.merge("id" => 42)
    runner = Object.new
    def runner.api(_path) = {"status" => "completed", "conclusion" => "success", "run_attempt" => 1}
    def runner.phase_evidence(*) = []
    result = RollingMonitor.check_run(item, run, proposal: {"head_sha" => "a" * 40}, runner: runner)
    assert_equal "evidence-missing-or-invalid", result.fetch("state")
    assert_equal 4, result.fetch("selections").length
  end
end
