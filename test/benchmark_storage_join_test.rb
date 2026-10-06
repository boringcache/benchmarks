# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/benchmark-storage"

class BenchmarkStorageJoinTest < Minitest::Test
  def record
    {"github" => {"run_id" => "42", "run_attempt" => "1"}, "action" => {"resolved_tags" => ["one", "two"]},
      "cache" => {"workspace" => "boringcache/benchmarks", "storage_bytes" => nil, "storage_source" => nil}}
  end

  def measurement
    {"kind" => "post-publication-storage", "github" => {"run_id" => "42", "run_attempt" => "1"},
      "identity" => {"workspace" => "boringcache/benchmarks", "tags" => ["two", "one"]}, "observed_at" => "2026-10-06T12:00:00Z",
      "evidence_file" => "original.json", "measurement" => {"bytes" => 0, "source" => "boringcache-check", "breakdown" => {"complete" => true}}}
  end

  def test_join_preserves_raw_record_and_accepts_measured_zero
    original = record
    joined = BenchmarkStorage.apply(original, [measurement])
    assert_nil original.dig("cache", "storage_bytes")
    assert_equal 0, joined.dig("cache", "storage_bytes")
    assert_equal original.fetch("cache").slice("storage_bytes", "storage_source"), joined.fetch("original_cache_measurement")
  end

  def test_join_rejects_other_attempt_tag_or_workspace
    [{"github" => {"run_id" => "42", "run_attempt" => "2"}},
      {"identity" => {"workspace" => "other", "tags" => ["one", "two"]}},
      {"identity" => {"workspace" => "boringcache/benchmarks", "tags" => ["one"]}}].each do |change|
      assert_equal record, BenchmarkStorage.apply(record, [measurement.merge(change)])
    end
  end
end
