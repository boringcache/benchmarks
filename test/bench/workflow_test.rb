require_relative "test_helper"
require "open3"
require "yaml"
require "tmpdir"

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

  def test_replays_run_in_the_rolling_job_pass_read_only_and_a_time_limit_and_never_publish
    jobs = YAML.load_file(File.expand_path("../../.github/workflows/project.yml", __dir__), aliases: true).fetch("jobs")
    phase = jobs.dig("rolling", "steps").find { it["uses"] == "./.github/actions/phase" }.fetch("with")

    assert_includes jobs.dig("rolling", "if"), "inputs.mode == 'replay'"
    assert_includes phase.fetch("phase"), "inputs.mode == 'replay'"
    assert_equal "${{ inputs.mode == 'replay' && inputs.read_only && 'true' || '' }}", phase.fetch("read-only")
    assert_equal "${{ inputs.mode == 'replay' && inputs.stop_after || '' }}", phase.fetch("stop-after")
    assert_includes jobs.dig("publish", "if"), "inputs.mode != 'replay'"
    assert_includes jobs.dig("plan", "steps").find { it["id"] == "matrix" }.fetch("run"), %(${REPLAY:+--replay --cache-scope "$CACHE_SCOPE"})
  end

  def test_a_stop_after_build_reports_a_stop_and_keeps_other_exit_statuses
    build = YAML.load_file(File.expand_path("../../.github/actions/phase/action.yml", __dir__)).dig("runs", "steps").find { it["id"] == "build" }.fetch("run")
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "bundle"), "#!/usr/bin/env bash\nsleep \"${STUB_SLEEP:-0}\"\nexit \"${STUB_STATUS:-0}\"\n")
      File.chmod(0o755, File.join(dir, "bundle"))
      [[{ "STOP_AFTER" => "1", "STUB_SLEEP" => "5" }, 0, true], [{ "STOP_AFTER" => "30", "STUB_STATUS" => "3" }, 3, false],
       [{ "STOP_AFTER" => "", "STUB_STATUS" => "0" }, 0, false], [{ "STOP_AFTER" => "", "STUB_STATUS" => "124" }, 124, false],
       [{ "STOP_AFTER" => "10m" }, 1, false]].each do |env, exit_status, stopped|
        output = File.join(dir, "output-#{env.values.join("-")}")
        _, status = Open3.capture2e({ "PATH" => "#{dir}:#{ENV["PATH"]}", "PROVIDER" => "remote", "GITHUB_OUTPUT" => output,
                                      "BENCH_CASE" => "demo/app", "BENCH_LANE" => "remote", **env }, "bash", "--noprofile", "--norc", "-eo", "pipefail", "-c", build)
        assert_equal exit_status, status.exitstatus, env.inspect
        assert_equal stopped, File.exist?(output) && File.read(output).include?("stopped=true"), env.inspect
      end
    end
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
