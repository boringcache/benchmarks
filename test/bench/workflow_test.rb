require_relative "test_helper"
require "open3"
require "yaml"

class WorkflowTest < Minitest::Test
  def test_missing_archive_is_excluded_after_the_timer_stops
    steps = YAML.load_file(File.expand_path("../../.github/actions/phase/action.yml", __dir__)).dig("runs", "steps")
    lookup = steps.find { it["id"] == "saved-archive" }
    assert lookup.dig("with", "lookup-only")
    assert_operator steps.index(lookup), :>, steps.index { it["run"]&.include?("bin/bench record ") }

    Dir.mktmpdir do |dir|
      path = File.join(dir, "record.json")
      script = File.expand_path("../../scripts/record-archive-save.rb", __dir__)
      original = { "seconds" => 24.5, "run_url" => "https://example.com/run" }
      ["true", "false", ""].each do |hit|
        File.write(path, JSON.generate(original))
        _, status = Open3.capture2e(RbConfig.ruby, script, path, "target-1", hit)
        record = JSON.parse(File.read(path))
        assert_equal(hit == "true", status.success?)
        assert_equal 24.5, record["seconds"]
        if status.success?
          assert_equal "target-1", record.fetch("cache_saved_key")
        else
          assert_includes record.fetch("excluded"), "target-1"
        end
      end
    end
  end

  def test_expired_bazel_job_budget_still_allows_the_record_step
    steps = YAML.load_file(File.expand_path("../../.github/actions/phase/action.yml", __dir__)).dig("runs", "steps")
    build = steps.find { it["id"] == "build" }
    assert build.fetch("continue-on-error")
    assert steps.drop(steps.index(build) + 1).any? { it["run"]&.include?("bin/bench record") }

    %w[bazel/codex bazel/codex-incredibuild].each do |kase|
      env = { "BENCH_CASE" => kase, "BENCH_BAZEL_DEADLINE" => (Time.now.to_i - 1).to_s }
      _, status = Open3.capture2e(env, "bash", "-e", "-o", "pipefail", "-c", build.fetch("run"))
      assert_equal 124, status.exitstatus
    end
  end

  def test_resource_samples_go_to_a_diagnostics_artifact
    steps = YAML.load_file(File.expand_path("../../.github/actions/phase/action.yml", __dir__)).dig("runs", "steps")
    sampler = steps.find { it["id"] == "sampler" }
    build = steps.find { it["id"] == "build" }
    artifact = steps.find { it.dig("with", "name").to_s.start_with?("diagnostics-") }
    assert_includes sampler.fetch("if"), "startsWith(inputs.case, 'bazel/codex')"
    assert_includes sampler.fetch("if"), "inputs.case == 'cargo/codex'"
    assert_includes sampler.fetch("run"), 'build-sampler.sh "$dir/samples.log" "$interval" > /dev/null 2>&1'
    refute_includes build.fetch("run"), "build-sampler.sh"
    assert_equal "${{ runner.temp }}/diagnostics", artifact.dig("with", "path")
  end

  def test_remote_cache_tokens_bypass_oidc_and_fail_if_a_required_token_is_missing
    steps = YAML.load_file(File.expand_path("../../.github/actions/phase/action.yml", __dir__)).dig("runs", "steps")
    script = steps.find { it["id"] == "build" }.fetch("run")
    stubs = <<~'BASH'
      bundle() { printf 'direct build\n'; }
      boringcache() { printf 'OIDC build\n'; }
    BASH
    env = {
      "BENCH_CASE" => "docker/posthog-runners", "BENCH_LANE" => "boringcache-docker-plus-hetzner",
      "BENCH_PHASE" => "rolling", "PROVIDER" => "boringcache", "STATIC_CACHE_AUTH" => "true",
      "BORINGCACHE_RESTORE_TOKEN" => "restore", "BORINGCACHE_SAVE_TOKEN" => "save"
    }

    output, status = Open3.capture2e(env, "bash", "-e", "-c", stubs + script)
    assert status.success?
    assert_equal "direct build\n", output

    env["BORINGCACHE_SAVE_TOKEN"] = ""
    output, status = Open3.capture2e(env, "bash", "-e", "-c", stubs + script)
    refute status.success?
    assert_includes output, "missing a required cache token"

    output, status = Open3.capture2e(env.merge("BENCH_PHASE" => "warm"), "bash", "-e", "-c", stubs + script)
    assert status.success?
    assert_equal "direct build\n", output

    output, status = Open3.capture2e(env.merge("STATIC_CACHE_AUTH" => "false", "BORINGCACHE_RESTORE_TOKEN" => ""), "bash", "-e", "-c", stubs + script)
    assert status.success?
    assert_equal "OIDC build\n", output
  end

  def test_mounted_series_stops_after_a_failed_phase
    jobs = YAML.load_file(File.expand_path("../../.github/workflows/project.yml", __dir__), aliases: true).fetch("jobs")
    %w[cold warm roll_1 roll_2 roll_3].each_cons(2) do |previous, current|
      gate = current == "warm" ? "!endsWith(inputs.lane, '-mounted')" : "inputs.lane != 'boringcache-cargo-plus-mounted'"
      assert_includes jobs.fetch(current).fetch("if"), "#{gate} || needs.#{previous}.result == 'success'"
    end
  end

  def test_branch_runs_collect_post_job_timings_without_publishing_to_main
    workflow = YAML.load_file(File.expand_path("../../.github/workflows/project.yml", __dir__), aliases: true)
    collect = workflow.fetch("jobs").fetch("collect")
    publish = workflow.fetch("jobs").fetch("publish")

    assert_equal %w[plan cold warm rolling roll_1 roll_2 roll_3], collect.fetch("needs")
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
     ["preflight", "refs/heads/topic", true], ["series", "refs/heads/topic", true], ["series", "refs/heads/main", false],
     ["series", "refs/tags/v1", false]].each do |mode, ref, allowed|
      env = { "REF" => ref, "ROLLING" => mode == "rolling" ? "true" : "", "SAMPLE" => mode == "sample" ? "true" : "", "BENCH_BRANCH_SERIES" => mode == "series" ? "true" : "" }
      output, status = Open3.capture2e(env, "bash", "-c", guard)
      assert_equal allowed, status.success?, "#{mode} on #{ref}: #{output}"
      assert_includes output, mode == "series" ? "branch other than main" : "--ref main" unless allowed
    end
  end
end
