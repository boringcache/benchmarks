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
    assert_equal "BC", payload["strategy_label"]
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

  def test_network_upload_bytes_use_oci_evidence_not_storage_size
    payload = write_artifact(
      "--cache-storage-bytes", "100",
      "--bytes-uploaded", "100",
      "--oci-new-blob-bytes", "3456"
    )

    assert_equal 100, payload.dig("cache", "storage_bytes")
    assert_equal 3456, payload.dig("oci", "new_blob_bytes")
    assert_equal 3456, payload.dig("transfer", "network_bytes_uploaded")
    assert_equal 3456, payload.dig("transfer", "bytes_uploaded")
    assert_equal "oci_new_blob_bytes", payload.dig("transfer", "network_bytes_uploaded_source")
  end

  def test_network_upload_bytes_can_be_passed_explicitly
    payload = write_artifact(
      "--cache-storage-bytes", "100",
      "--network-bytes-uploaded", "4567"
    )

    assert_equal 4567, payload.dig("transfer", "network_bytes_uploaded")
    assert_equal 4567, payload.dig("transfer", "bytes_uploaded")
    assert_equal "network_bytes_uploaded_input", payload.dig("transfer", "network_bytes_uploaded_source")
  end

  def test_cache_review_projects_session_summary_for_rails
    Dir.mktmpdir("bc-artifact-inputs") do |dir|
      summary_path = File.join(dir, "summary.json")
      File.write(summary_path, JSON.generate(
        "summary_schema" => "cache_session_summary.v2",
        "summary_session_id" => "session-123",
        "tool" => "bazel",
        "cache_target" => "grpc-bazel",
        "project_hints" => ["grpc"],
        "phase_hints" => ["rolling"],
        "metrics" => {
          "total_hits" => 12,
          "total_misses" => 3,
          "total_errors" => 1,
          "total_bytes_read" => 2048,
          "total_bytes_written" => 4096,
          "duration_seconds" => 9.5
        },
        "review" => {
          "primary_bottleneck" => "native_tool_work",
          "diagnostic" => {
            "classification" => "cache_miss_quality",
            "label" => "Partial remote reuse"
          },
          "customer_state" => "fast_but_not_skipping",
          "customer_summary" => "Bazel used the remote cache, but still executed local analysis work.",
          "service_side_issue" => false,
          "operator_issue" => true,
          "value_outcome" => "needs_native_diagnostics",
          "value_owner" => "adapter",
          "value_headline" => "Remote hits are present; native work remains.",
          "value_detail" => "Profile flags can explain the remaining time.",
          "value_next_action" => "Enable diagnose mode for one run.",
          "value_evidence" => ["12 cache hits", "3 misses"],
          "issue_candidates" => [
            {
              "kind" => "cache_miss_quality",
              "owner" => "adapter",
              "surface" => "bazel",
              "severity" => "investigate",
              "confidence" => 0.75,
              "summary" => "Misses remain after a warm import.",
              "suggested_action" => "Inspect the profile.",
              "evidence_refs" => ["raw-only"]
            }
          ]
        }
      ))

      payload = write_artifact("--cache-session-summary-json", summary_path)

      review = payload.fetch("cache_review")
      assert_equal "benchmark_cache_review.v1", review["schema_version"]
      assert_equal "cache_session_summary.v2", review["summary_schema"]
      assert_equal "session-123", review["summary_session_id"]
      assert_equal "bazel", review["tool"]
      assert_equal "grpc-bazel", review["cache_target"]
      assert_equal ["grpc"], review["project_hints"]
      assert_equal ["rolling"], review["phase_hints"]
      assert_equal "native_tool_work", review["primary_bottleneck"]
      assert_equal "cache_miss_quality", review["diagnostic_classification"]
      assert_equal "Partial remote reuse", review["diagnostic_label"]
      assert_equal "fast_but_not_skipping", review["customer_state"]
      assert_equal "Bazel used the remote cache, but still executed local analysis work.", review["customer_summary"]
      assert_equal false, review["service_side_issue"]
      assert_equal true, review["operator_issue"]
      assert_equal "needs_native_diagnostics", review["value_outcome"]
      assert_equal "adapter", review["value_owner"]
      assert_equal "Remote hits are present; native work remains.", review["value_headline"]
      assert_equal "Profile flags can explain the remaining time.", review["value_detail"]
      assert_equal "Enable diagnose mode for one run.", review["value_next_action"]
      assert_equal ["12 cache hits", "3 misses"], review["value_evidence"]
      assert_equal 12, review["hit_count"]
      assert_equal 3, review["miss_count"]
      assert_equal 80.0, review["hit_rate"]
      assert_equal 1, review["error_count"]
      assert_equal 2048, review["bytes_read"]
      assert_equal 4096, review["bytes_written"]
      assert_equal 9.5, review["duration_seconds"]

      candidate = review.fetch("issue_candidates").fetch(0)
      assert_equal "cache_miss_quality", candidate["kind"]
      assert_equal "adapter", candidate["owner"]
      assert_equal "bazel", candidate["surface"]
      assert_equal "investigate", candidate["severity"]
      assert_equal 0.75, candidate["confidence"]
      refute_includes candidate.keys, "evidence_refs"

      assert_equal 12, payload.dig("slow_reason", "hit_count")
      assert_equal 3, payload.dig("slow_reason", "miss_count")
      assert_equal 80.0, payload.dig("slow_reason", "hit_rate")
    end
  end

  def test_cache_review_projects_cache_session_v2_shape
    Dir.mktmpdir("bc-artifact-inputs") do |dir|
      summary_path = File.join(dir, "summary.json")
      File.write(summary_path, JSON.generate(
        "schema" => "cache-session-v2",
        "session_id" => "proxy-summary-123",
        "adapter" => "oci",
        "workspace" => "boringcache/benchmark-hugo",
        "tag" => "hugo-rolling-main",
        "mode" => "docker-registry",
        "duration_ms" => 2731,
        "storage" => {
          "bytes" => 6601,
          "oci_engine_storage_get_bytes" => 6601
        },
        "oci" => {
          "oci_engine_borrowed_upload_session_bytes" => 6601,
          "oci_engine_publish_total_duration_ms" => 561
        },
        "startup_prefetch" => {
          "startup_prefetch_oci_duration_ms" => 593
        },
        "classification" => {
          "bottleneck" => {
            "state" => "cache_side_clear",
            "evidence" => {
              "hits" => 25,
              "misses" => 0,
              "hit_rate" => 100.0,
              "errors" => 0
            }
          },
          "cache_temperature" => {
            "state" => "hot",
            "hits" => 25,
            "misses" => 0,
            "hit_rate" => 100.0,
            "errors" => 0
          }
        }
      ))

      payload = write_artifact("--cache-session-summary-json", summary_path)

      review = payload.fetch("cache_review")
      assert_equal "cache-session-v2", review["summary_schema"]
      assert_equal "proxy-summary-123", review["summary_session_id"]
      assert_equal "oci", review["tool"]
      assert_equal "boringcache/benchmark-hugo", review.dig("cache_target", "workspace")
      assert_equal "cache_side_clear", review["primary_bottleneck"]
      assert_equal "cache_side_clear", review["diagnostic_classification"]
      assert_equal ["native_tool_work"], review["reason_codes"]
      assert_equal 25, review["hit_count"]
      assert_equal 0, review["miss_count"]
      assert_equal 100.0, review["hit_rate"]
      assert_equal 0, review["error_count"]
      assert_equal 6601, review["bytes_read"]
      assert_equal 6601, review["bytes_written"]
      assert_in_delta 2.731, review["duration_seconds"], 0.001

      assert_equal 25, payload.dig("slow_reason", "hit_count")
      assert_equal 0, payload.dig("slow_reason", "miss_count")
      assert_equal 100.0, payload.dig("slow_reason", "hit_rate")
    end
  end

  def test_cache_review_fetches_session_payload_from_api_by_provider_run_id
    Dir.mktmpdir("bc-artifact-inputs") do |dir|
      curl_path = File.join(dir, "curl")
      File.write(curl_path, <<~BASH)
        #!/usr/bin/env bash
        printf '%s\n' '{"sessions":[{"session_id":"api-session-123","run_uid":"github-actions:boringcache/benchmark-hugo:12345","summary_schema":"cache_session_summary.v2","tool":"gocache","hit_count":7,"miss_count":1,"hit_rate":87.5,"error_count":0,"bytes_read":2048,"bytes_written":512,"duration_seconds":4.2,"review":{"primary_bottleneck":"cache_miss_quality","summary":"One miss remains after restore.","issue_candidates":[{"kind":"cache_miss_quality","owner":"adapter","surface":"go","severity":"investigate"}]}}]}'
      BASH
      File.chmod(0o755, curl_path)

      payload = write_artifact(
        "--workspace", "boringcache/benchmark-hugo",
        "--run-uid", "gh-12345-1",
        env: {
          "PATH" => "#{dir}:#{ENV.fetch("PATH")}",
          "BORINGCACHE_RESTORE_TOKEN" => "test-token",
          "GITHUB_RUN_ID" => "12345"
        }
      )

      review = payload.fetch("cache_review")
      assert_equal "api-session-123", review["summary_session_id"]
      assert_equal "gocache", review["tool"]
      assert_equal "cache_miss_quality", review["primary_bottleneck"]
      assert_equal ["cache_miss_quality"], review["reason_codes"]
      assert_equal 7, review["hit_count"]
      assert_equal 1, review["miss_count"]
      assert_equal 87.5, review["hit_rate"]
      assert_equal "cache_miss_quality", review.dig("issue_candidates", 0, "kind")
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

  def test_rolling_docker_import_with_zero_cached_steps_is_investigation_only
    payload = write_artifact(
      "--cache-import-status", "ok",
      "--mode", "docker",
      "--adapter", "oci",
      "--buildkit-cached-steps", "0",
      "--oci-new-blob-count", "89",
      "--oci-new-blob-bytes", "9418062725",
      benchmark: "posthog-native"
    )

    assert_equal true, payload.dig("classification", "sample_valid")
    assert_equal "investigation_only", payload.dig("classification", "reporting_mode")
    assert_equal "rolling_cache_import_no_reuse", payload.dig("classification", "reporting_reason")
    assert_equal "rolling_import_no_reuse", payload.dig("classification", "rolling_reseed_kind")
    assert_equal false, payload.dig("classification", "steady_state_candidate")
    assert_equal "no_reuse", payload.dig("classification", "cache_import_status")
    assert_equal "ok", payload.dig("classification", "raw_cache_import_status")
    assert_equal "no_reuse", payload.dig("classification", "cache_reuse_status")
    assert_equal 0, payload.dig("docker_cache", "cached_steps")
    assert_equal 0, payload.dig("slow_reason", "buildkit_cached_steps")
    assert_equal "metadata_import_no_reuse", payload.dig("slow_reason", "prior_cache_state")

    hypothesis_ids = payload.dig("slow_reason", "hypotheses").map { |row| row.fetch("id") }
    assert_includes hypothesis_ids, "docker_import_without_reuse"
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

  def test_sccache_stats_are_normalized_as_native_tool_evidence
    Dir.mktmpdir("bc-artifact-inputs") do |dir|
      stats_path = File.join(dir, "sccache-stats.txt")
      File.write(stats_path, <<~STATS)
        Compile requests                  2613
        Compile requests executed         2305
        Cache hits                         2173
        Cache hits (C/C++)                  666
        Cache hits (Rust)                  1366
        Cache misses                        124
        Cache misses (Rust)                 124
        Cache timeouts                        0
        Cache read errors                     0
        Cache write errors                    0
        Cache errors                          0
        Non-cacheable calls                 299
        Non-cacheable reasons:
        crate-type                          252
        -o                                   30

        Average cache read hit            0.004 s
        Average cache write               0.011 s
        Average compiler                 29.316 s
      STATS

      payload = write_artifact(
        "--sccache-stats-file", stats_path,
        benchmark: "zed-sccache",
        strategy: "depot-cache"
      )

      native_tool = payload.fetch("native_tool")
      assert_equal "native_tool_evidence.v1", native_tool["schema_version"]
      assert_equal "sccache", native_tool["tool"]
      assert_equal 2613, native_tool["compile_requests"]
      assert_equal 2305, native_tool["compile_requests_executed"]
      assert_equal 2173, native_tool["cache_hits"]
      assert_equal 124, native_tool["cache_misses"]
      assert_equal 94.6, native_tool["hit_rate"]
      assert_equal 1366, native_tool.dig("hit_counts", "rust")
      assert_equal 124, native_tool.dig("miss_counts", "rust")
      assert_equal 299, native_tool["non_cacheable_calls"]
      assert_equal 252, native_tool.dig("non_cacheable_reasons", "crate-type")
      assert_equal 0.004, native_tool["average_cache_read_hit_seconds"]
      assert_equal 0.011, native_tool["average_cache_write_seconds"]
      assert_equal 29.316, native_tool["average_compiler_seconds"]

      review = payload.fetch("cache_review")
      assert_equal "sccache", review["tool"]
      assert_equal "cache_miss_quality", review["primary_bottleneck"]
      assert_includes review["reason_codes"], "cache_miss_quality"
      assert_includes review["reason_codes"], "native_tool_work"
      assert_equal 2173, review["hit_count"]
      assert_equal 124, review["miss_count"]
      assert_equal 94.6, review["hit_rate"]

      assert_equal 2173, payload.dig("slow_reason", "hit_count")
      assert_equal 124, payload.dig("slow_reason", "miss_count")
      assert_equal "cache_miss_quality", payload.dig("slow_reason", "hypotheses").find { |row| row["id"] == "cache_miss_quality" }.fetch("id")
      assert_equal "native_tool_work", payload.dig("slow_reason", "hypotheses").find { |row| row["id"] == "native_tool_work" }.fetch("id")
    end
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
    assert_equal "GHA", payload["strategy_label"]
  end

  def test_third_party_strategy_labels_are_written
    depot = write_artifact(benchmark: "hugo-go", strategy: "depot-cache", lane: "fresh")
    buildbuddy = write_artifact(benchmark: "grpc-bazel", strategy: "buildbuddy-cache", lane: "fresh")

    assert_equal "Depot", depot["strategy_label"]
    assert_equal "BuildBuddy", buildbuddy["strategy_label"]
  end

  private

  def write_artifact(*extra_args, benchmark: "hugo", strategy: "boringcache", lane: "rolling", env: {})
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

      stdout, stderr, status = Open3.capture3(env, *command)
      assert status.success?, "artifact writer failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
      JSON.parse(File.read(File.join(dir, "#{benchmark}-#{strategy}-#{lane}.json")))
    end
  end
end
