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

  def test_reports_only_the_cases_it_is_given
    record "a.json", seconds: 10.0

    assert_equal 1, Bench::Report.new(@dir, cases: ["docker/posthog"]).rows.size
    assert_empty Bench::Report.new(@dir, cases: ["docker/hugo"]).rows
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
                    "| docker | posthog | gha | base | github | cold | - | aaaaaaaaaaaa | 1.40.1 | 1 | - | post-job | github 4c | AMD EPYC 7763 | 4 | 1 | 1 | 0 | unmeasured | unmeasured | unmeasured |"
  end

  private
    def record(name, seconds:, exit_status: 0, output_ok: true, phase: "cold", scope: "gha-github-1", sha: "a" * 40, step: nil,
               boringcache: "1.40.1", release: nil, attempt: nil, cpu: "AMD EPYC 7763", save: "post-job")
      File.write(File.join(@dir, name), JSON.generate(
        "adapter_command" => "docker", "case" => "posthog", "lane" => "gha", "level" => "base", "runner" => "github",
        "phase" => phase, "step" => step, "scope" => scope, "sha" => sha, "seconds" => seconds, "attempt" => attempt,
        "exit_status" => exit_status, "output_ok" => output_ok, "cache_save_timing" => save, "machine" => "github 4c",
        "observed" => { "machine" => { "cpu" => cpu, "cores" => 4 } }, "versions" => { "boringcache" => boringcache, "boringcache_release" => release }.compact
      ))
    end
end
