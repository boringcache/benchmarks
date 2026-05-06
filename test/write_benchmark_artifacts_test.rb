# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class WriteBenchmarkArtifactsTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/canonical/write-benchmark-artifacts.sh", __dir__)

  def test_rolling_imported_oci_updates_are_valid_first_build_data
    payload = write_artifact(
      "--cache-import-status", "ok",
      "--oci-new-blob-count", "12",
      "--oci-new-blob-bytes", "3456"
    )

    assert_equal true, payload.dig("classification", "sample_valid")
    assert_equal "comparative", payload.dig("classification", "reporting_mode")
    assert_nil payload.dig("classification", "reporting_reason")
    assert_equal false, payload.dig("classification", "rolling_reseed")
    assert_equal "none", payload.dig("classification", "rolling_reseed_kind")
    assert_equal "Rolling", payload["lane_label"]
    assert_equal "Commit build", payload["first_build_label"]
    assert_equal 10, payload.dig("runs", "rolling_first_build_seconds")
    assert_nil payload.dig("runs", "rolling_warm_seconds")
  end

  def test_rolling_import_miss_stays_investigation_only
    payload = write_artifact(
      "--cache-import-status", "proxy_unreadable",
      "--oci-new-blob-count", "12",
      "--oci-new-blob-bytes", "3456"
    )

    assert_equal "investigation_only", payload.dig("classification", "reporting_mode")
    assert_equal "rolling_cache_import_not_ok", payload.dig("classification", "reporting_reason")
    assert_equal "Rolling cache import was unavailable, so this sample populated the rolling cache and is excluded from parity claims.", payload.dig("classification", "reporting_note")
    assert_equal "rolling_bootstrap_or_cache_evicted", payload.dig("classification", "rolling_reseed_kind")
  end

  def test_native_tool_labels_are_inferred_for_actions_cache_artifacts
    payload = write_artifact(
      benchmark: "storybook",
      strategy: "actions-cache",
      lane: "rolling"
    )

    assert_equal "nx", payload["mode"]
    assert_equal "nx", payload["adapter"]
  end

  def test_startup_prefetch_fields_are_written
    payload = write_artifact(
      "--startup-prefetch-duration-ms", "152000",
      "--startup-prefetch-target-blobs", "16555",
      "--startup-prefetch-target-bytes", "865049699",
      "--startup-prefetch-concurrency", "100",
      "--startup-prefetch-initial-concurrency", "20",
      "--startup-prefetch-final-concurrency", "100",
      "--startup-prefetch-max-observed-concurrency", "100",
      "--startup-prefetch-concurrency-reason", "many_small_blobs_rtt_bound",
      "--startup-prefetch-retries", "2",
      "--startup-prefetch-failures", "0"
    )

    assert_equal 152_000, payload.dig("startup_prefetch", "duration_ms")
    assert_equal 16_555, payload.dig("startup_prefetch", "target_blobs")
    assert_equal 865_049_699, payload.dig("startup_prefetch", "target_bytes")
    assert_equal 100, payload.dig("startup_prefetch", "concurrency")
    assert_equal 20, payload.dig("startup_prefetch", "initial_concurrency")
    assert_equal 100, payload.dig("startup_prefetch", "final_concurrency")
    assert_equal 100, payload.dig("startup_prefetch", "max_observed_concurrency")
    assert_equal "many_small_blobs_rtt_bound", payload.dig("startup_prefetch", "concurrency_reason")
    assert_equal 2, payload.dig("startup_prefetch", "retries")
    assert_equal 0, payload.dig("startup_prefetch", "failures")
  end

  def test_actions_cache_rolling_miss_is_investigation_only
    payload = write_artifact(
      "--cache-import-status", "actions_cache_miss",
      benchmark: "storybook",
      strategy: "actions-cache",
      lane: "rolling"
    )

    assert_equal "investigation_only", payload.dig("classification", "reporting_mode")
    assert_equal "rolling_cache_import_not_ok", payload.dig("classification", "reporting_reason")
    assert_equal "actions_cache_miss", payload.dig("classification", "cache_import_status")
  end

  private

  def write_artifact(*extra_args, benchmark: "hugo", strategy: "boringcache", lane: "rolling")
    Dir.mktmpdir("bc-artifacts") do |dir|
      command = [
        SCRIPT,
        "--benchmark", benchmark,
        "--strategy", strategy,
        "--lane", lane,
        "--project-repo", "gohugoio/hugo",
        "--project-ref", "abc",
        "--cold-seconds", "10",
        "--cold-build-seconds", "8",
        "--cache-storage-bytes", "100",
        "--output-dir", dir,
        *extra_args
      ]

      stdout, stderr, status = Open3.capture3(*command)
      assert status.success?, "artifact writer failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
      JSON.parse(File.read(File.join(dir, "#{benchmark}-#{strategy}-#{lane}.json")))
    end
  end
end
