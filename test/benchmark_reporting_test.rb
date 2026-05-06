# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/benchmark-reporting"

class BenchmarkReportingTest < Minitest::Test
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
    assert_equal "Commit Build", summary["headline_label"]
    assert_equal "cache bootstrap 2/3", summary["result_text"]
    assert_equal "Rolling cache was unavailable for 2/3 samples; those samples populated the rolling cache and are excluded from parity claims.", summary["note"]
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
    assert_equal "Rolling cache was unavailable for 1/2 samples; those samples populated the rolling cache and are excluded from parity claims.", rollup["reporting_note"]
    assert_equal 1, rollup["rolling_bootstrap_count"]
    assert_equal 1, rollup["rolling_reseed_count"]
  end
end
