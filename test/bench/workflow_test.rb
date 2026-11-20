require_relative "test_helper"
require "open3"
require "yaml"

class WorkflowTest < Minitest::Test
  def test_expired_bazel_job_budget_still_allows_the_record_step
    steps = YAML.load_file(File.expand_path("../../.github/actions/phase/action.yml", __dir__)).dig("runs", "steps")
    build = steps.find { it["id"] == "build" }
    assert build.fetch("continue-on-error")
    assert steps.drop(steps.index(build) + 1).any? { it["run"]&.include?("bin/bench record") }

    env = { "BENCH_CASE" => "bazel/codex", "BENCH_BAZEL_DEADLINE" => (Time.now.to_i - 1).to_s }
    _, status = Open3.capture2e(env, "bash", "-e", "-o", "pipefail", "-c", build.fetch("run"))
    assert_equal 124, status.exitstatus
  end

  def test_branch_runs_collect_post_job_timings_without_publishing_to_main
    workflow = YAML.load_file(File.expand_path("../../.github/workflows/project.yml", __dir__), aliases: true)
    collect = workflow.fetch("jobs").fetch("collect")
    publish = workflow.fetch("jobs").fetch("publish")

    assert_equal %w[plan cold warm rolling], collect.fetch("needs")
    refute_includes collect.fetch("if"), "refs/heads/main"
    assert_equal "read", collect.dig("permissions", "contents")
    assert_equal "read", collect.dig("permissions", "actions")
    assert collect.fetch("steps").any? { it["run"]&.include?("bin/bench post-job-saves") }
    artifact = collect.fetch("steps").find { it["uses"]&.start_with?("actions/upload-artifact@") }
    assert_equal "recorded-results-${{ github.run_attempt }}", artifact.dig("with", "name")
    assert_equal %w[plan collect], publish.fetch("needs")
    assert_includes publish.fetch("if"), "needs.collect.result == 'success'"
    assert_includes publish.fetch("if"), "github.ref == 'refs/heads/main'"
    download = publish.fetch("steps").find { it["uses"]&.start_with?("actions/download-artifact@") }
    assert_equal artifact.dig("with", "name"), download.dig("with", "name")
  end

  def test_rolling_and_sample_runs_are_refused_outside_main
    workflow = YAML.load_file(File.expand_path("../../.github/workflows/project.yml", __dir__), aliases: true)
    step = workflow.dig("jobs", "plan", "steps").find { it["id"] == "matrix" }
    assert_equal "${{ github.ref }}", step.dig("env", "REF")
    guard = step.fetch("run").split("bash scripts/checkout-records.sh").first

    [["rolling", "refs/heads/topic", false], ["sample", "refs/heads/topic", false], ["rolling", "refs/tags/v1", false],
     ["rolling", "refs/heads/main", true], ["sample", "refs/heads/main", true], ["fresh", "refs/heads/topic", true],
     ["preflight", "refs/heads/topic", true]].each do |mode, ref, allowed|
      env = { "REF" => ref, "ROLLING" => mode == "rolling" ? "true" : "", "SAMPLE" => mode == "sample" ? "true" : "" }
      output, status = Open3.capture2e(env, "bash", "-c", guard)
      assert_equal allowed, status.success?, "#{mode} on #{ref}: #{output}"
      assert_includes output, "--ref main" unless allowed
    end
  end
end
