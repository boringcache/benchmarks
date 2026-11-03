require "minitest/autorun"
require_relative "../../lib/bench/native_link"

class NativeLinkTest < Minitest::Test
  def prefix(phase, run_id = "41458232286")
    Bench::NativeLink.prefix("BENCH_CASE" => "bazel/llvm", "BENCH_PHASE" => phase, "BENCH_RUN_ID" => run_id)
  end

  def test_rolling_keeps_the_series_store
    assert_equal "nativelink/bazel/llvm", prefix("rolling")
    assert_equal prefix("rolling"), prefix("rolling", "41516558320")
  end

  def test_fresh_phases_share_one_run_store
    assert_equal "nativelink/bazel/llvm/runs/41458232286", prefix("cold")
    assert_equal prefix("cold"), prefix("warm")
  end

  def test_other_runs_never_reach_the_series_store
    stores = %w[preflight cold warm sample].map { prefix(it) }
    stores.each { refute it.start_with?("nativelink/bazel/llvm/cas/", "nativelink/bazel/llvm/ac/") }
    refute_equal prefix("cold"), prefix("cold", "41494248980")
  end
end
