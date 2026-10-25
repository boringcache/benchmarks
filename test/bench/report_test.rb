require_relative "test_helper"

class ReportTest < Minitest::Test
  def test_latest_failure_is_visible_when_only_older_steps_are_comparable
    %w[boringcache-docker gha].each do |lane|
      (0..2).each do |step|
        record "#{lane}-#{step}.json", lane:, phase: "rolling", step:, seconds: 10.0, save: "in-phase",
          scope: "#{lane}-github-rolling", exit_status: lane == "boringcache-docker" && step == 2 ? 1 : 0
      end
    end
    report = Bench::Report.new(@dir)
    latest = report.latest.find { it["lane"] == "boringcache-docker" }
    assert_equal [2, "failed", nil], latest.values_at("step", "status", "seconds")
    assert_equal [1], report.matched.map { it["last_step"] }.uniq
  end

  def test_latest_exclusion_is_visible_without_becoming_a_measurement
    record "excluded.json", seconds: 1.0, phase: "rolling", step: 2, save: "in-phase"
    path = File.join(@dir, "excluded.json")
    File.write(path, JSON.generate(JSON.parse(File.read(path)).merge("excluded" => "Provider served no cache")))
    report = Bench::Report.new(@dir)

    assert_empty report.rows
    assert_equal ["excluded", nil, "Provider served no cache"], report.latest.first.values_at("status", "seconds", "excluded")
  end

  def test_runner_samples_keep_operations_and_failed_post_job_saves_visible
    Dir.mktmpdir("samples-report") do |dir|
      base = { "adapter_command" => "docker", "case" => "chroma", "phase" => "sample", "runner" => "blacksmith-8", "machine" => "blacksmith 8c",
               "sha" => "a" * 40, "seconds" => 20.0, "exit_status" => 0, "output_ok" => true, "run_url" => "https://example.test/runs/1" }
      File.write(File.join(dir, "cache.json"), JSON.generate(base.merge("lane" => "boringcache-reader", "provider" => "boringcache", "read_only" => true,
        "cache_source" => { "run_url" => "https://example.test/runs/0" })))
      File.write(File.join(dir, "native.json"), JSON.generate(base.merge("lane" => "blacksmith-builder", "provider" => "blacksmith", "cache_save_timing" => "post-job", "job_conclusion" => "failure")))
      rows = Bench::Report.new(dir).samples.to_h { [it["lane"], it] }
      assert_empty Bench::Report.new(dir).rows
      assert_equal ["GitHub build", "restore, build", 20.0], rows["boringcache-reader"].values_at("cache", "operations", "seconds")
      assert_nil rows["blacksmith-builder"]["seconds"]
      assert_equal "failure", rows["blacksmith-builder"]["job_conclusion"]
    end
  end
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
    assert_equal({ "samples" => 4, "failed" => 1, "seed_failed" => 0, "save_failed" => 0, "median_seconds" => 20.0, "min_seconds" => 10.0, "max_seconds" => 30.0 },
                 rows.first.slice("samples", "failed", "seed_failed", "save_failed", "median_seconds", "min_seconds", "max_seconds"))
  end

  def test_reports_only_the_lanes_and_runners_its_cases_still_run
    record "a.json", seconds: 10.0

    assert_equal 1, Bench::Report.new(@dir, runs: ["docker/posthog gha github"]).rows.size
    assert_empty Bench::Report.new(@dir, runs: ["docker/posthog gha github-arm"]).rows
    assert_empty Bench::Report.new(@dir, runs: ["docker/hugo gha github"]).rows
  end

  def test_sample_only_provider_history_does_not_block_rolling_comparisons
    %w[boringcache-docker gha depot-builder].each do |lane|
      (0..2).each do |step|
        next if lane == "depot-builder" && step == 2

        record "#{lane}-#{step}.json", lane:, seconds: 10.0, phase: "rolling", step:, save: "in-phase", scope: "#{lane}-github-rolling"
      end
    end
    record "depot-sample.json", lane: "depot-builder", seconds: 12.0, phase: "sample", step: 2, save: "in-phase"
    runs = %w[boringcache-docker gha].map { "docker/posthog #{it} github" }
    report = Bench::Report.new(@dir, runs:, sample_runs: ["docker/posthog depot-builder github"])

    assert_equal [2], report.matched.map { it["last_step"] }.uniq
    assert_equal ["depot-builder"], report.samples.map { it["lane"] }
    refute report.rows.any? { it["lane"] == "depot-builder" }
  end
  def test_experimental_records_are_excluded_from_public_rows_and_matched_steps
    %w[boringcache-docker gha experiment].each do |lane|
      (0..2).each do |step|
        record "#{lane}-#{step}.json", lane:, seconds: 10.0, phase: "rolling", step:, save: "in-phase", scope: "#{lane}-github-rolling", experimental: lane == "experiment"
      end
    end

    report = Bench::Report.new(@dir)
    assert_equal %w[boringcache-docker gha], report.rows.map { it["lane"] }.uniq.sort
    assert_equal %w[boringcache-docker gha], report.matched.map { it["lane"] }.uniq.sort
  end

  def test_excluded_records_stay_out_of_rows_and_matched_steps
    %w[boringcache-docker gha].each do |lane|
      (0..3).each { record "#{lane}-#{it}.json", lane:, seconds: 10.0, phase: "rolling", step: it, scope: "#{lane}-github-rolling", save: "in-phase" }
    end
    path = File.join(@dir, "gha-2.json")
    File.write(path, JSON.generate(JSON.parse(File.read(path)).merge("excluded" => "Depot Cache returned HTTP 402 on every request")))

    report = Bench::Report.new(@dir)
    assert_equal [0, 1, 3], report.rows.select { it["lane"] == "gha" }.map { it["step"] }
    assert_equal [[2, 1, 3]], report.matched.select { it["lane"] == "gha" }.map { it.values_at("steps", "first_step", "last_step") }
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

  def test_a_post_job_failure_is_not_a_timing_or_a_warm_seed
    record "cold.json", seconds: 100.0, post_job_save: 28.5, job_conclusion: "failure"
    record "warm.json", seconds: 10.0, phase: "warm"

    rows = Bench::Report.new(@dir).rows
    assert_equal [1, nil], rows.find { it["phase"] == "cold" }.values_at("failed", "median_seconds")
    assert_equal [1, nil], rows.find { it["phase"] == "warm" }.values_at("seed_failed", "median_seconds")
  end

  def test_a_post_job_failure_excludes_the_step_from_matched_results
    %w[boringcache-docker gha].each do |lane|
      (0..2).each do |step|
        record "#{lane}-#{step}.json", lane:, seconds: 10.0, phase: "rolling", step:, post_job_save: 1.0, scope: "#{lane}-github-rolling",
          restored: :unrecorded, job_conclusion: lane == "gha" && step == 2 ? "failure" : "success"
      end
    end

    assert_equal [[1, 1, 1], [1, 1, 1]], Bench::Report.new(@dir).matched.map { it.values_at("steps", "first_step", "last_step") }
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

  def test_a_rolling_step_that_restored_an_older_steps_cache_is_a_stale_restore
    record "0.json", seconds: 90.0, phase: "rolling", save: "in-phase", step: 0, scope: "gha-github-rolling", restore_tracked: true
    record "1.json", seconds: 10.0, phase: "rolling", save: "in-phase", step: 1, scope: "gha-github-rolling", restored: "docker-posthog-gha-github-rolling-0"
    record "2.json", seconds: 11.0, phase: "rolling", save: "in-phase", step: 2, scope: "gha-github-rolling", restored: "docker-posthog-gha-github-rolling-1"
    record "3.json", seconds: 40.0, phase: "rolling", save: "in-phase", step: 3, scope: "gha-github-rolling", restored: "docker-posthog-gha-github-rolling-1"
    record "4.json", seconds: 12.0, phase: "rolling", save: "in-phase", step: 4, scope: "gha-github-rolling", restored: "docker-posthog-gha-github-rolling-2-3"
    record "5.json", seconds: 45.0, phase: "rolling", save: "in-phase", step: 5, scope: "gha-github-rolling", restored: "docker-posthog-gha-github-rolling-3"

    report = Bench::Report.new(@dir)
    assert_equal [[0, 90.0], [0, 10.0], [0, 11.0], [1, nil], [0, 12.0], [1, nil]], report.rows.sort_by { it["step"] }.map { it.values_at("seed_failed", "median_seconds") }
    assert_equal "stale restore", report.latest.first["status"]
  end

  def test_a_step_after_an_excluded_step_that_restored_the_step_before_it_is_a_stale_restore
    (0..3).each do |step|
      record "#{step}.json", seconds: 10.0, phase: "rolling", step:, scope: "gha-github-rolling", restore_tracked: true,
        restored: ("docker-posthog-gha-github-rolling-#{step == 3 ? 1 : step - 1}" if step.positive?)
    end
    path = File.join(@dir, "2.json")
    File.write(path, JSON.generate(JSON.parse(File.read(path)).merge("excluded" => "Provider served no cache")))

    assert_equal [[0, 0], [1, 0], [3, 1]], Bench::Report.new(@dir).rows.map { it.values_at("step", "seed_failed") }
  end

  def test_a_failed_cache_save_is_a_failure_and_a_skipped_one_is_not
    %w[boringcache-docker gha].each do |lane|
      (0..3).each do |step|
        record "#{lane}-#{step}.json", lane:, seconds: 10.0, phase: "rolling", step:, save: "in-phase", scope: "#{lane}-github-rolling",
          cache_save: ({ 2 => "failed", 3 => "skipped" }[step] if lane == "gha")
      end
    end

    report = Bench::Report.new(@dir)
    gha = report.rows.select { it["lane"] == "gha" }.sort_by { it["step"] }
    assert_equal [[0, 0, 10.0], [0, 0, 10.0], [1, 1, nil], [0, 0, 10.0]], gha.map { it.values_at("failed", "save_failed", "median_seconds") }
    assert_equal [[2, 1, 3]], report.matched.select { it["lane"] == "gha" }.map { it.values_at("steps", "first_step", "last_step") }
    record "gha-4.json", seconds: 10.0, phase: "rolling", step: 4, save: "in-phase", scope: "gha-github-rolling", cache_save: "failed", exit_status: 1
    record "boringcache-docker-4.json", lane: "boringcache-docker", seconds: 10.0, phase: "rolling", step: 4, save: "in-phase", scope: "boringcache-docker-github-rolling", cache_save: "failed"
    assert_equal({ "boringcache-docker" => "save failed", "gha" => "failed" }, Bench::Report.new(@dir).latest.to_h { it.values_at("lane", "status") })
  end

  def test_rows_split_by_commit_step_and_cli_version
    record "a.json", seconds: 10.0, sha: "a" * 40
    record "b.json", seconds: 20.0, sha: "b" * 40
    record "c.json", seconds: 30.0, sha: "b" * 40, boringcache: "1.41.0"
    record "d.json", seconds: 40.0, sha: "b" * 40, phase: "rolling", step: 3

    assert_equal 4, Bench::Report.new(@dir).rows.size
  end

  def test_a_tracked_cache_that_has_never_restored_is_unseeded_after_its_first_step
    (0..2).each do |step|
      record "#{step}.json", seconds: 10.0, phase: "rolling", step:, scope: "gha-github-rolling", restore_tracked: true
    end

    assert_equal [[0, 10.0], [1, nil], [1, nil]], Bench::Report.new(@dir).rows.map { it.values_at("seed_failed", "median_seconds") }
  end

  def test_product_settings_are_reported_with_the_cli_version
    record "default.json", seconds: 20.0
    File.write(File.join(@dir, "selective.json"), JSON.generate(JSON.parse(File.read(File.join(@dir, "default.json"))).merge("product_env" => { "BORINGCACHE_ARCHIVE_SELECTIVE_READS" => "1" }, "plan_settings" => { "target-budget" => "25GiB" })))

    assert_equal ["1.40.1", "1.40.1 BORINGCACHE_ARCHIVE_SELECTIVE_READS=1 target-budget=25GiB"], Bench::Report.new(@dir).rows.map { it["boringcache"] }.sort
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
                    "| docker | posthog | gha | base | github | cold | - | aaaaaaaaaaaa | 1.40.1 | 1 | - | post-job | github 4c | AMD EPYC 7763 | 4 | 1 | 1 | 0 | 0 | unmeasured | unmeasured | unmeasured | - |\n"
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

  def test_a_lane_with_no_passing_steps_still_prevents_an_incomplete_comparison
    %w[boringcache-docker gha failed].each do |lane|
      (0..2).each do |step|
        record "#{lane}-#{step}.json", lane:, seconds: 10.0, phase: "rolling", step:, scope: "#{lane}-github-rolling", save: "in-phase", exit_status: lane == "failed" ? 1 : 0
      end
    end

    assert_empty Bench::Report.new(@dir).matched
  end

  def test_lanes_on_different_commits_are_not_matched
    %w[boringcache-docker gha].each do |lane|
      (0..2).each do |step|
        record "#{lane}-#{step}.json", lane:, seconds: 10.0, phase: "rolling", step:, scope: "#{lane}-github-rolling", save: "in-phase", sha: (lane == "gha" ? "a" : "b") * 40
      end
    end

    assert_empty Bench::Report.new(@dir).matched
  end

  def test_a_lane_that_joins_later_starts_a_new_matched_group_and_keeps_the_earlier_steps
    { "boringcache-docker" => 0, "gha" => 0, "ghcr" => 2 }.each do |lane, first|
      (first..4).each { record "#{lane}-#{it}.json", lane:, seconds: 10.0 * (it + 1), phase: "rolling", step: it, scope: "#{lane}-github-rolling", save: "in-phase" }
    end

    groups = Bench::Report.new(@dir).matched.group_by { it["lane"] }.transform_values { |rows| rows.map { it.values_at("first_step", "last_step") } }
    assert_equal [[1, 2], [3, 4]], groups["boringcache-docker"]
    assert_equal [[3, 4]], groups["ghcr"]
  end

  def test_nightly_lanes_are_matched_with_each_other_and_do_not_hold_back_every_step_lanes
    %w[boringcache-docker gha].each do |lane|
      (0..6).each { record "#{lane}-#{it}.json", lane:, seconds: 10.0, phase: "rolling", step: it, scope: "#{lane}-github-rolling", save: "in-phase" }
    end
    { "depot-builder" => "github", "boringcache-docker" => "depot-8" }.each do |lane, runner|
      [0, 1, 2, 3, 5].each do |step|
        record "#{lane}-#{runner}-#{step}.json", lane:, runner:, seconds: 20.0, phase: "rolling", step:, scope: "#{lane}-#{runner}-rolling", save: "in-phase", cadence: ("nightly" if step >= 3)
      end
    end

    report = Bench::Report.new(@dir, nightly: ["docker/posthog depot-builder github", "docker/posthog boringcache-docker depot-8"])
    assert_equal [["github", "boringcache-docker", 1, 2], ["github", "boringcache-docker", 3, 6], ["github", "depot-builder", 1, 2], ["github", "gha", 1, 2], ["github", "gha", 3, 6],
                  ["nightly", "boringcache-docker", 5, 5], ["nightly", "depot-builder", 5, 5]],
                 report.matched.map { it.values_at("runner", "lane", "first_step", "last_step") }.sort
    assert_equal "depot 8c", report.matched.find { it["runner"] == "nightly" && it["lane"] == "boringcache-docker" }["machine"]
    assert_equal [[1, 2]], Bench::Report.new(@dir).matched.select { it["runner"] == "github" }.map { it.values_at("first_step", "last_step") }.uniq
  end

  def test_read_only_steps_pair_with_the_step_of_the_lane_they_read_when_they_started_before_it_saved
    %w[boringcache-docker gha].each do |lane|
      (0..4).each { record "#{lane}-#{it}.json", lane:, seconds: 10.0 * (it + 1), phase: "rolling", step: it, scope: "#{lane}-github-rolling", save: "in-phase", started_at: "2026-10-19T10:00:00Z" }
    end
    { "github" => 5.0, "namespace-4" => 3.0 }.each do |runner, seconds|
      (1..4).each do |step|
        record "reader-#{runner}-#{step}.json", lane: "boringcache-docker-reader", runner:, seconds: seconds * step, phase: "rolling", step:, scope: "boringcache-docker-reader-#{runner}-rolling",
                                                cache_scope: "boringcache-docker-github-rolling", save: "in-phase", read_only: true, sha: step == 3 && runner == "github" ? "b" * 40 : "a" * 40,
                                                started_at: step == 4 ? "2026-10-19T10:00:50Z" : "2026-10-19T10:00:05Z"
      end
    end

    report = Bench::Report.new(@dir)
    assert_equal %w[boringcache-docker gha], report.matched.map { it["lane"] }.uniq.sort
    assert_equal [["github 4c", 2, 1, 2, 7.5, 25.0], ["namespace 4c", 3, 1, 3, 6.0, 30.0]],
                 report.read_only.map { it.values_at("machine", "steps", "first_step", "last_step", "median_seconds", "source_median_seconds") }
    assert_equal ["boringcache-docker-github-rolling"], report.read_only.map { it["reads"] }.uniq
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
               boringcache: "1.40.1", release: nil, attempt: nil, cpu: "AMD EPYC 7763", save: "post-job", restored: nil, post_job_save: nil, errors: nil, experimental: false, restore_tracked: false, job_conclusion: nil, runner: "github", cadence: nil, read_only: nil, started_at: nil, cache_save: nil)
      File.write(File.join(@dir, name), JSON.generate({
        "adapter_command" => "docker", "case" => "posthog", "lane" => lane, "level" => "base", "runner" => runner,
        "phase" => phase, "step" => step, "scope" => scope, "cache_scope" => cache_scope, "sha" => sha, "seconds" => seconds, "attempt" => attempt, "experimental" => experimental, "cache_restore_tracked" => restore_tracked,
        "exit_status" => exit_status, "output_ok" => output_ok, "cache_save_timing" => save, "machine" => { "depot-8" => "depot 8c", "namespace-4" => "namespace 4c" }.fetch(runner, "github 4c"),
        "observed" => { "machine" => { "cpu" => cpu, "cores" => 4 } }, "versions" => { "boringcache" => boringcache, "boringcache_release" => release }.compact
      }.merge(restored == :unrecorded ? {} : { "cache_restored_key" => restored }, post_job_save ? { "post_job_save_seconds" => post_job_save } : {},
              job_conclusion ? { "job_conclusion" => job_conclusion } : {}, cadence ? { "cadence" => cadence } : {}, read_only ? { "read_only" => true } : {}, started_at ? { "started_at" => started_at } : {},
              cache_save ? { "cache_save" => cache_save } : {},
              errors ? { "provider_reported" => { "cache_session_summary" => { "backend_api" => { "total_error_count" => errors } } } } : {})))
    end
end
