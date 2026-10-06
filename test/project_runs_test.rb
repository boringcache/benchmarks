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

  def test_suite_groups_different_tools_for_the_same_upstream_project
    runs = BenchmarkCadence.fresh_targets.map do |target|
      {"repository" => BenchmarkCases::REPOSITORY, "workflow" => target.fetch("fresh_workflow"),
        "inputs" => target.fetch("fresh_inputs"), "series" => {"case_id" => target.fetch("case_id")}}
    end
    grouped = ProjectRuns.group(runs, lane: "fresh")
    assert_equal 22, grouped.length
    %w[hugo zed].each do |project|
      run = grouped.find { |value| value.dig("inputs", "case_id") == project && value["selections"] }
      assert_equal 2, run.fetch("selections").length
      matrices = ProjectRuns.matrix(JSON.parse(run.dig("inputs", "selections")), case_id: project, lane: "fresh")
      assert_equal 2, matrices.values.sum { |value| value.fetch("include").length }
    end
  end

  def test_missing_project_phases_remain_visible
    rows = ProjectReport.observations([], selections: selections.map { |run| run.slice("workflow", "inputs") },
      project: "n8n", lane: "fresh", run_url: "https://example.com/run/42")
    assert_equal 16, rows.length
    assert_equal ["missing"], rows.map { |row| row.fetch("state") }.uniq
    assert rows.all? { |row| row["storage_bytes"].nil? }
    assert_includes ProjectReport.markdown(rows, project: "n8n"), "unmeasured"
  end

  def test_runner_group_keeps_each_seed_replay_and_job_result_separate
    selections = %w[depot-ubuntu-24.04-4 namespace-profile-buildkit-4c].map do |label|
      {"workflow" => "native-fresh-benchmark.yml", "inputs" => {"case_id" => "posthog", "variant" => "layers",
        "provider" => "boringcache", "runner_label" => label, "benchmark_id_suffix" => "-#{label.tr('.', '-')}"}}
    end
    matrix = ProjectRuns.matrix(selections, case_id: "posthog", lane: "fresh")
    assert_equal ["layers depot-ubuntu-24.04-4", "layers namespace-profile-buildkit-4c"], matrix.fetch("native-fresh-benchmark.yml").fetch("include").map { |row| row.fetch("label") }
    records = selections.flat_map.with_index do |selection, index|
      %w[cold warm].map do |phase|
        {"case" => {"case_id" => "posthog"}, "variant" => "layers", "benchmark" => "posthog#{selection.dig('inputs', 'benchmark_id_suffix')}",
          "strategy" => "boringcache", "phase" => phase, "verification" => {"passed" => true}, "timing" => {"build_seconds" => 10 + index}}
      end
    end
    jobs = selections.flat_map.with_index do |selection, index|
      %w[cold warm].map do |phase|
        {"name" => "layers #{selection.dig('inputs', 'runner_label')} / BoringCache posthog #{phase}",
          "status" => "completed", "conclusion" => index.zero? ? "success" : "failure"}
      end
    end
    rows = ProjectReport.observations(records, selections: selections, project: "posthog", lane: "fresh", jobs: jobs, run_url: "https://example.com/run/42")
    assert_equal %w[succeeded succeeded failed failed], rows.map { |row| row.fetch("state") }
    assert_equal [10, 10, 11, 11], rows.map { |row| row.dig("timing", "build_seconds") }
    assert_equal selections.map { |value| value.dig("inputs", "runner_label") }, rows.map { |row| row.fetch("runner_class") }.uniq
    selections.last.fetch("inputs")["benchmark_id_suffix"] = selections.first.dig("inputs", "benchmark_id_suffix")
    assert_raises(RuntimeError) { ProjectRuns.matrix(selections, case_id: "posthog", lane: "fresh") }
  end

  def test_checked_in_posthog_runner_selections_prepare_distinct_workloads
    selections = JSON.parse(File.read(File.join(BenchmarkCases::ROOT, "cases/posthog/runner-screen-selections.json")))
    item = BenchmarkCases.load_case("posthog")
    identities = Dir.mktmpdir do |root|
      selections.map.with_index do |selection, index|
        inputs = selection.fetch("inputs")
        BenchmarkCases.plan(item, workflow: selection.fetch("workflow"), inputs: inputs)
        directory = BenchmarkCases.prepare(item, directory: File.join(root, index.to_s), native_lane: "fresh",
          variant: inputs.fetch("variant"), suffix: inputs.fetch("benchmark_id_suffix"))
        action = YAML.safe_load_file(File.join(directory, ".github/actions/benchmark-phase/action.yml"))
        action.dig("runs", "steps", 1, "env", "BENCHMARK_ID")
      end
    end
    assert_equal 4, identities.uniq.length
    bad = selections.first.fetch("inputs").merge("benchmark_id_suffix" => "-depot-ubuntu-24.04-4")
    assert_raises(NativeCase::Error) { BenchmarkCases.plan(item, inputs: bad) }
  end

  def test_rolling_zed_matrix_preserves_cargo_and_nix_inputs
    selections = [
      {"repository" => BenchmarkCases::REPOSITORY, "workflow" => "zed-zed-cargo-rolling-auto.yml", "inputs" => {"base_sha" => "a" * 40, "head_sha" => "b" * 40, "source_distance" => "3"}},
      {"repository" => BenchmarkCases::REPOSITORY, "workflow" => "nix-rolling-benchmark.yml", "inputs" => {"case_id" => "zed-nix", "provider" => "all"}}
    ]
    run = ProjectRuns.group(selections, lane: "rolling").fetch(0)
    assert_equal "project-rolling.yml", run.fetch("workflow")
    matrices = ProjectRuns.matrix(JSON.parse(run.dig("inputs", "selections")), case_id: "zed", lane: "rolling")
    assert_equal %w[nix-rolling-benchmark.yml zed-zed-cargo-rolling-auto.yml], matrices.keys.sort
    assert_equal selections.first.fetch("inputs"), matrices.fetch("zed-zed-cargo-rolling-auto.yml").fetch("include").first.fetch("inputs")
    assert_raises(RuntimeError) { ProjectRuns.matrix(JSON.parse(run.dig("inputs", "selections")), case_id: "hugo", lane: "rolling") }
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
