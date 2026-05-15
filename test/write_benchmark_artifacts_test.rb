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

  def test_slow_reason_row_normalizes_timings_and_hypotheses
    Dir.mktmpdir("bc-artifact-inputs") do |dir|
      summary_path = File.join(dir, "summary.json")
      issue_candidates_path = File.join(dir, "issue-candidates.json")
      File.write(summary_path, JSON.generate(
        "tool" => {
          "cache_read_hit_count" => 100,
          "cache_read_miss_count" => 39
        }
      ))
      File.write(issue_candidates_path, JSON.generate([
        {
          "kind" => "storage_ttfb_regression",
          "owner" => "boringcache",
          "severity" => "investigate"
        }
      ]))

      payload = write_artifact(
        "--cache-import-status", "ok",
        "--docker-cache-import-seconds", "0.1",
        "--docker-cache-export-seconds", "437.8",
        "--oci-new-blob-bytes", "5580986362",
        "--cache-session-summary-json", summary_path,
        "--issue-candidates-json", issue_candidates_path,
        "--paired-run-id", "25922740871",
        "--prior-cache-state", "warm_mixed"
      )

      slow_reason = payload.fetch("slow_reason")
      assert_equal "benchmark_slow_reason.v1", slow_reason["schema_version"]
      assert_equal "25922740871", slow_reason["paired_run_id"]
      assert_equal 8, slow_reason["build_seconds"]
      assert_equal 2, slow_reason["setup_seconds"]
      assert_equal 0.1, slow_reason["cache_restore_seconds"]
      assert_equal 437.8, slow_reason["cache_save_export_seconds"]
      assert_equal 100, slow_reason["hit_count"]
      assert_equal 39, slow_reason["miss_count"]
      assert_equal 71.9, slow_reason["hit_rate"]
      assert_equal "warm_mixed", slow_reason["prior_cache_state"]
      assert_equal 5_580_986_362, slow_reason["new_blob_bytes"]
      assert_equal "storage_ttfb_regression", slow_reason.dig("issue_candidates", 0, "kind")

      hypothesis_ids = slow_reason.fetch("hypotheses").map { |hypothesis| hypothesis.fetch("id") }
      assert_includes hypothesis_ids, "cache_save_export_overhead"
      assert_includes hypothesis_ids, "partial_cache_reuse"
      assert_includes hypothesis_ids, "large_cache_update"
      assert_includes hypothesis_ids, "mcp_issue_candidate_present"
    end
  end

  def test_slow_reason_uses_action_timing_breakdown_when_docker_timings_are_absent
    Dir.mktmpdir("bc-artifact-inputs") do |dir|
      timings_path = File.join(dir, "action-timings.json")
      File.write(timings_path, JSON.generate(
        "phases" => {
          "seed" => {
            "archive_restore" => {
              "total_seconds" => 12.5
            },
            "archive_save" => {
              "total_seconds" => 22.25,
              "post_step_non_save_seconds" => 5.5
            }
          }
        }
      ))

      payload = write_artifact("--action-timings-json", timings_path)

      assert_equal 12.5, payload.dig("slow_reason", "cache_restore_seconds")
      assert_equal 22.25, payload.dig("slow_reason", "cache_save_export_seconds")
      assert_equal 5.5, payload.dig("slow_reason", "post_cleanup_seconds")
    end
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

  def test_storage_breakdown_and_tool_outcomes_are_written
    Dir.mktmpdir("bc-artifact-inputs") do |dir|
      storage_path = File.join(dir, "storage.json")
      tool_outcomes_path = File.join(dir, "tool-outcomes.json")
      File.write(storage_path, JSON.generate(
        "summary" => {
          "remote_cas_bytes" => 256,
          "dependency_archive_bytes" => 512,
          "tool_runtime_archive_bytes" => 128
        },
        "components" => []
      ))
      File.write(tool_outcomes_path, JSON.generate(
        "gradle" => {
          "warm1" => {
            "executed_tasks" => 12,
            "from_cache_tasks" => 34,
            "up_to_date_tasks" => 5
          }
        },
        "warnings" => ["warm1_executed_tasks_high"]
      ))

      payload = write_artifact(
        "--storage-breakdown-json", storage_path,
        "--tool-outcomes-json", tool_outcomes_path
      )

      assert_equal 256, payload.dig("cache", "storage_breakdown", "summary", "remote_cas_bytes")
      assert_equal 12, payload.dig("tool_outcomes", "gradle", "warm1", "executed_tasks")
    end
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
