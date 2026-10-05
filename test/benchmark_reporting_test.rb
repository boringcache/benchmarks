# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/benchmark-reporting"

class BenchmarkReportingTest < Minitest::Test
  def test_time_differences_keep_both_directions_and_small_differences
    assert_equal "+0.125s", BenchmarkReporting.timing_difference(10, 10.125)
    assert_equal "-2s", BenchmarkReporting.timing_difference(10, 8)
    assert_equal "0s", BenchmarkReporting.timing_difference(10, 10)
    assert_equal "unmeasured", BenchmarkReporting.timing_difference(nil, 10)
  end

  def test_phase_display_keeps_fractional_seconds
    assert_equal "0.125s", BenchmarkReport.seconds(0.125)
    assert_equal "61.25s", BenchmarkReport.seconds(61.25)
    assert_equal "0s", BenchmarkReport.seconds(0)
    assert_equal "unmeasured", BenchmarkReport.seconds(nil)
  end

  def test_storage_difference_keeps_measured_zero_and_both_directions
    assert_equal "-200 bytes", BenchmarkReporting.storage_difference(200)
    assert_equal "+200 bytes", BenchmarkReporting.storage_difference(-200)
    assert_equal "0 bytes", BenchmarkReporting.storage_difference(0)
    assert_equal "unmeasured", BenchmarkReporting.storage_difference(nil)
  end

  def test_cargo_summary_preserves_fractional_time_and_missing_hit_rate
    Dir.mktmpdir do |dir|
      path = File.join(dir, "evidence.json")
      File.write(path, JSON.generate("phases" => {"restore" => {"mode_evidence" => {
        "elapsed_seconds" => 0.125, "native_tool" => {"cache_hits" => 1, "cache_misses" => 2}
      }}}))
      output, status = Open3.capture2e({"GITHUB_STEP_SUMMARY" => nil}, RbConfig.ruby,
        File.expand_path("../scripts/summarize-cargo-evidence.rb", __dir__), "Cargo", path)
      assert status.success?, output
      assert_includes output, "elapsed: 0.125s"
      assert_includes output, "hit rate: unmeasured"
      refute_includes output, "0.0%"
    end
  end

  def test_successful_import_uses_the_shared_ok_status
    warm = BenchmarkReporting.warm_classification({ "cache_hit" => true })
    rolling = BenchmarkReporting.rolling_classification({ "cache_hit" => true })

    assert_equal "ok", warm["cache_import_status"]
    assert_equal "ok", rolling["cache_import_status"]
  end

  def test_unmeasured_docker_restore_stays_unknown
    warm = BenchmarkReporting.warm_classification({ "cache_import_ready" => nil }, "docker")

    assert_equal "unknown", warm["cache_import_status"]
    assert_equal "provider does not expose warm restore evidence", warm["validity_reason"]
  end

  def test_rolling_bootstrap_uses_current_public_language
    summary = BenchmarkReporting.reporting_summary(
      lane: "rolling",
      category: "docker",
      classification: {
        "reporting_mode" => "investigation_only",
        "reporting_reason" => "rolling_reseed",
        "rolling_reseed_count" => 2
      },
      sample_count: 3
    )

    assert_equal false, summary["comparative"]
    assert_equal "investigation_only", summary["status"]
    assert_equal "rolling_cache_bootstrap", summary["reason"]
    assert_equal "Changed-source build", summary["headline_label"]
    assert_equal "cache bootstrap 2/3", summary["result_text"]
    assert_equal "Rolling cache was unavailable for 2/3 samples; cache restore did not report a hit for those samples.", summary["note"]
  end

  def test_rollup_keeps_legacy_count_and_adds_bootstrap_count
    rollup = BenchmarkReporting.rollup_classification(
      lane: "rolling",
      category: "docker",
      classifications: [
        { "rolling_reseed" => true, "reporting_reason" => "rolling_reseed" },
        { "steady_state_candidate" => true }
      ]
    )

    assert_equal "comparative", rollup["reporting_mode"]
    assert_equal "rolling_cache_bootstrap", rollup["reporting_reason"]
    assert_equal "Rolling cache was unavailable for 1/2 samples; cache restore did not report a hit for those samples.", rollup["reporting_note"]
    assert_equal 1, rollup["rolling_bootstrap_count"]
    assert_equal 1, rollup["rolling_reseed_count"]
  end
end
