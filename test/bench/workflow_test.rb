require_relative "test_helper"
require "yaml"

class WorkflowTest < Minitest::Test
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
end
