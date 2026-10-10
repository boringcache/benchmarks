require_relative "test_helper"

class ReportTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir("results")
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  def test_groups_records_and_keeps_failures
    record "a.json", seconds: 10.0
    record "b.json", seconds: 30.0
    record "c.json", seconds: 20.0
    record "d.json", seconds: 99.0, exit_status: 1, output_ok: false

    rows = Bench::Report.new(@dir).rows
    assert_equal 1, rows.size
    assert_equal({ "samples" => 4, "failed" => 1, "seed_failed" => 0, "median_seconds" => 20.0, "min_seconds" => 10.0, "max_seconds" => 30.0 },
                 rows.first.slice("samples", "failed", "seed_failed", "median_seconds", "min_seconds", "max_seconds"))
  end

  def test_reports_only_the_lanes_and_runners_its_cases_still_run
    record "a.json", seconds: 10.0

    assert_equal 1, Bench::Report.new(@dir, runs: ["docker/posthog gha github"]).rows.size
    assert_empty Bench::Report.new(@dir, runs: ["docker/posthog gha github-arm"]).rows
    assert_empty Bench::Report.new(@dir, runs: ["docker/hugo gha github"]).rows
  end

  def test_failed_output_checks_and_missing_status_are_failures_not_timings
    record "a.json", seconds: 100.0
    record "b.json", seconds: 1.0, output_ok: false
    record "c.json", seconds: 2.0, output_ok: nil
    record "d.json", seconds: 3.0, exit_status: nil

    row = Bench::Report.new(@dir).rows.first
    assert_equal [4, 3, 100.0], row.values_at("samples", "failed", "median_seconds")
  end

  def test_a_warm_after_a_failed_cold_is_a_seed_failure
    record "cold-ok.json", seconds: 50.0, scope: "lane-github-1"
    record "warm-ok.json", seconds: 5.0, phase: "warm", scope: "lane-github-1"
    record "cold-bad.json", seconds: 40.0, scope: "lane-github-2", exit_status: 1, output_ok: false
    record "warm-after-bad.json", seconds: 30.0, phase: "warm", scope: "lane-github-2"

    warm = Bench::Report.new(@dir).rows.find { it["phase"] == "warm" }
    assert_equal [2, 0, 1, 5.0], warm.values_at("samples", "failed", "seed_failed", "median_seconds")
  end

  def test_a_measured_post_job_save_is_added_to_the_timing
    record "dance.json", seconds: 100.0, phase: "rolling", step: 1, save: "post-job", post_job_save: 28.5
    record "unmeasured.json", seconds: 90.0, phase: "rolling", step: 2, save: "post-job"

    rows = Bench::Report.new(@dir).rows.sort_by { it["step"] }
    assert_equal [["post-job, timed", 128.5], ["post-job", 90.0]], rows.map { it.values_at("cache_save_timing", "median_seconds") }
  end

  def test_a_rolling_step_that_restored_nothing_from_its_lanes_cache_is_a_seed_failure
    record "start.json", seconds: 90.0, phase: "rolling", step: 0, scope: "gha-github-rolling"
    record "hit.json", seconds: 10.0, phase: "rolling", step: 1, scope: "gha-github-rolling", restored: "docker-posthog-gha-github-rolling-0"
    record "evicted.json", seconds: 80.0, phase: "rolling", step: 2, scope: "gha-github-rolling"
    record "before-the-field.json", seconds: 70.0, phase: "rolling", step: 3, scope: "gha-github-rolling", restored: :unrecorded
    record "no-actions-cache.json", seconds: 60.0, phase: "rolling", step: 4, scope: "boringcache-github-rolling"

    rows = Bench::Report.new(@dir).rows.sort_by { it["step"] }
    assert_equal [[0, 90.0], [0, 10.0], [1, nil], [0, 70.0], [0, 60.0]], rows.map { it.values_at("seed_failed", "median_seconds") }
  end

  def test_rows_split_by_commit_step_and_cli_version
    record "a.json", seconds: 10.0, sha: "a" * 40
    record "b.json", seconds: 20.0, sha: "b" * 40
    record "c.json", seconds: 30.0, sha: "b" * 40, boringcache: "1.41.0"
    record "d.json", seconds: 40.0, sha: "b" * 40, phase: "rolling", step: 3

    assert_equal 4, Bench::Report.new(@dir).rows.size
  end

  def test_a_canary_is_reported_by_its_release_tag
    record "release.json", seconds: 20.0
    record "canary.json", seconds: 10.0, release: "vcli-canary-0123456789ab"

    assert_equal ["1.40.1", "vcli-canary-0123456789ab"], Bench::Report.new(@dir).rows.map { it["boringcache"] }.sort
  end

  def test_retries_cpus_and_save_timings_are_reported_separately
    record "first.json", seconds: 100.0, phase: "rolling", step: 3, attempt: 1
    record "retry.json", seconds: 5.0, phase: "rolling", step: 3, attempt: 2
    record "intel.json", seconds: 90.0, phase: "rolling", step: 3, attempt: 1, cpu: "Intel(R) Xeon(R) 6973P-C"
    record "in-phase.json", seconds: 80.0, phase: "rolling", step: 3, attempt: 1, save: "in-phase"

    rows = Bench::Report.new(@dir).rows
    assert_equal [5.0, 80.0, 90.0, 100.0], rows.map { it["median_seconds"] }.sort
    assert_equal [1, 2], rows.map { it["attempt"] }.uniq.sort
  end

  def test_missing_values_are_unmeasured_in_markdown
    record "a.json", seconds: 5.0, exit_status: 2, output_ok: false

    assert_includes Bench::Report.new(@dir).markdown,
                    "| docker | posthog | gha | base | github | cold | - | aaaaaaaaaaaa | 1.40.1 | 1 | - | post-job | github 4c | AMD EPYC 7763 | 4 | 1 | 1 | 0 | unmeasured | unmeasured | unmeasured | - |\n"
  end

  def test_rows_carry_the_cache_api_errors_the_product_reported
    record "a.json", seconds: 10.0, errors: 205
    record "b.json", seconds: 20.0, sha: "b" * 40

    assert_equal [205, nil], Bench::Report.new(@dir).rows.map { it["cache_api_errors"] }
  end

  def test_matched_steps_need_every_lane_on_the_runner_past_its_first_step_on_its_own_rolling_cache
    { "boringcache-docker" => [90.0, 10.0, 20.0, 30.0, 40.0], "gha" => [80.0, 15.0, 25.0, 35.0, 45.0] }.each do |lane, times|
      times.each_with_index do |seconds, step|
        record "#{lane}-#{step}.json", lane:, seconds:, phase: "rolling", save: "in-phase", step:, scope: "#{lane}-github-rolling",
                                       restored: (lane == "gha" && step.positive? ? "docker-posthog-gha-github-rolling-#{step - 1}" : nil),
                                       errors: (lane == "boringcache-docker" && step == 4 ? 3 : nil)
      end
    end
    record "gha-2-failed.json", lane: "gha", seconds: 1.0, phase: "rolling", save: "in-phase", step: 2, scope: "gha-github-rolling", attempt: 1, exit_status: 1, output_ok: false
    record "boringcache-docker-5.json", lane: "boringcache-docker", seconds: 50.0, phase: "rolling", save: "in-phase", step: 5, scope: "boringcache-docker-github-rolling"
    record "gha-5-evicted.json", lane: "gha", seconds: 55.0, phase: "rolling", save: "in-phase", step: 5, scope: "gha-github-rolling"
    record "gha-6-from-fresh.json", lane: "gha", seconds: 5.0, phase: "rolling", save: "in-phase", step: 6, scope: "gha-github-rolling", cache_scope: "gha-github-123",
                                    restored: "docker-posthog-gha-github-123-5"
    record "boringcache-docker-6.json", lane: "boringcache-docker", seconds: 60.0, phase: "rolling", save: "in-phase", step: 6, scope: "boringcache-docker-github-rolling"
    record "boringcache-docker-7.json", lane: "boringcache-docker", seconds: 70.0, phase: "rolling", save: "in-phase", step: 7, scope: "boringcache-docker-github-rolling"
    record "gha-7-untimed-save.json", lane: "gha", seconds: 7.0, phase: "rolling", step: 7, scope: "gha-github-rolling", restored: "docker-posthog-gha-github-rolling-6"

    matched = Bench::Report.new(@dir).matched
    assert_equal [["boringcache-docker", 4, 1, 4, 25.0, 1], ["gha", 4, 1, 4, 30.0, 0]],
                 matched.map { it.values_at("lane", "steps", "first_step", "last_step", "median_seconds", "cache_api_error_steps") }
    assert_includes Bench::Report.new(@dir).markdown, "| docker | posthog | github | rolling | 1.40.1 | 4 | 1 | 4 | gha | base | github 4c | 30.0 | 15.0 | 45.0 | 0 |"
  end

  def test_a_runner_with_one_lane_has_no_matched_steps
    (0..2).each { record "#{it}.json", lane: "boringcache-docker", seconds: 10.0, phase: "rolling", step: it, scope: "boringcache-docker-github-rolling" }

    assert_empty Bench::Report.new(@dir).matched
  end

  def test_matched_steps_split_by_cli_version_and_rolling_series
    %w[boringcache-docker ghcr].each do |lane|
      [["1.40.2", "rolling"], ["1.41.0", "rolling"], ["1.41.0", "rolling-2"]].each_with_index do |(cli, series), index|
        (0..2).each do |step|
          record "#{lane}-#{index}-#{step}.json", lane:, seconds: 10.0 * (step + 1), phase: "rolling", step: step + (cli == "1.41.0" && series == "rolling" ? 3 : 0),
                                                  scope: "#{lane}-github-#{series}", boringcache: cli, save: "in-phase"
        end
      end
    end

    assert_equal [["rolling", "1.40.2", 2], ["rolling", "1.41.0", 3], ["rolling-2", "1.41.0", 2]],
                 Bench::Report.new(@dir).matched.select { it["lane"] == "ghcr" }.map { it.values_at("series", "boringcache", "steps") }
  end

  private
    def record(name, seconds:, exit_status: 0, output_ok: true, phase: "cold", scope: "gha-github-1", sha: "a" * 40, step: nil, lane: "gha", cache_scope: scope,
               boringcache: "1.40.1", release: nil, attempt: nil, cpu: "AMD EPYC 7763", save: "post-job", restored: nil, post_job_save: nil, errors: nil)
      File.write(File.join(@dir, name), JSON.generate({
        "adapter_command" => "docker", "case" => "posthog", "lane" => lane, "level" => "base", "runner" => "github",
        "phase" => phase, "step" => step, "scope" => scope, "cache_scope" => cache_scope, "sha" => sha, "seconds" => seconds, "attempt" => attempt,
        "exit_status" => exit_status, "output_ok" => output_ok, "cache_save_timing" => save, "machine" => "github 4c",
        "observed" => { "machine" => { "cpu" => cpu, "cores" => 4 } }, "versions" => { "boringcache" => boringcache, "boringcache_release" => release }.compact
      }.merge(restored == :unrecorded ? {} : { "cache_restored_key" => restored }, post_job_save ? { "post_job_save_seconds" => post_job_save } : {},
              errors ? { "provider_reported" => { "cache_session_summary" => { "backend_api" => { "total_error_count" => errors } } } } : {})))
    end
end
