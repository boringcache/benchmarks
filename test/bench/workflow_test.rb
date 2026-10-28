require_relative "test_helper"
require "yaml"

class WorkflowTest < Minitest::Test
  def test_memory_samples_reach_the_job_log_without_changing_the_build_exit_status
    action = YAML.load_file(File.join(Bench::ROOT, ".github/actions/phase/action.yml"))
    script = action.fetch("runs").fetch("steps").find { it["id"] == "build" }.fetch("run")

    Dir.mktmpdir("phase-diagnostics") do |dir|
      FileUtils.mkdir_p(["#{dir}/bin", "#{dir}/diagnostics"])
      File.write("#{dir}/diagnostics/machine.txt", "memory machine fixture\n")
      File.write("#{dir}/diagnostics/samples.log", "MemAvailable: 123456 kB\n")
      File.write("#{dir}/bin/bundle", "#!/usr/bin/env bash\nsleep 1.1\nexit \"$BUILD_STATUS\"\n")
      File.chmod(0o755, "#{dir}/bin/bundle")
      env = { "PATH" => "#{dir}/bin:#{ENV.fetch('PATH')}", "RUNNER_TEMP" => dir,
        "PROVIDER" => "test", "BENCH_CASE" => "cargo/zed", "BENCH_LANE" => "test" }

      [0, 7].each do |exit_status|
        output, status = Open3.capture2e(env.merge("BUILD_STATUS" => exit_status.to_s), "bash", "-eo", "pipefail", "-c", script)
        assert_equal exit_status, status.exitstatus
        assert_includes output, "memory machine fixture"
        assert_includes output, "MemAvailable: 123456 kB"
      end

      FileUtils.rm_rf("#{dir}/diagnostics")
      output, status = Open3.capture2e(env.merge("BUILD_STATUS" => "7"), "bash", "-eo", "pipefail", "-c", script)
      assert_equal 7, status.exitstatus
      assert_empty output
    end
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
end
