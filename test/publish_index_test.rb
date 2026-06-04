# frozen_string_literal: true

require "minitest/autorun"
require "rbconfig"
require_relative "../scripts/publish-index"

class PublishIndexTest < Minitest::Test
  PRODUCT_REFS = {
    "action_ref" => "boringcache/one@v1",
    "action_sha" => "0123456789abcdef0123456789abcdef01234567",
    "cli_version" => "v1.12.86",
    "web_revision" => "89abcdef0123456789abcdef0123456789abcdef",
    "api_url" => "https://app.boringcache.com"
  }.freeze

  def test_strategy_snapshot_preserves_release_and_launch_proof_fields
    metrics = extract_strategy_metrics(raw_boringcache_artifact)
    snapshot = strategy_snapshot({
      run: {
        "databaseId" => 123,
        "url" => "https://github.com/boringcache/benchmark-hugo/actions/runs/123",
        "headSha" => "feedface",
        "createdAt" => "2026-05-04T10:00:00Z"
      },
      run_total_seconds: 42.0,
      metrics: metrics
    }, 456)

    assert_equal PRODUCT_REFS, snapshot["product_refs"]
    assert_equal true, snapshot["product_refs_consistent"]
    assert_equal "metadata-only", snapshot.dig("oci", "hydration_policy")
    assert_equal 152_000, snapshot.dig("startup_prefetch", "duration_ms")
    assert_equal 100, snapshot.dig("startup_prefetch", "concurrency")
    assert_equal "many_small_blobs_rtt_bound", snapshot.dig("startup_prefetch", "concurrency_reason")
    assert_equal 25, snapshot["cold_build_seconds"]
    assert_equal 5, snapshot["cold_restore_or_setup_seconds"]
    assert_equal 3, snapshot["warm1_build_seconds"]
    assert_equal 1, snapshot["warm1_restore_or_setup_seconds"]
    assert_equal 30, snapshot["rolling_first_build_seconds"]
    assert_equal 4, snapshot["rolling_warm_seconds"]
    assert_equal ["docker/action/fresh_runner_rerun"], snapshot["launch_proof_paths"]
    assert_equal "boringcache/benchmarks", snapshot["workspace"]
    assert_equal "hugo-docker-main", snapshot["cache_tag"]
    assert_equal "gh-123-1", snapshot["run_uid"]
    assert_equal "docker", snapshot["mode"]
    assert_equal "oci", snapshot["adapter"]
    assert_equal ["cache:hugo-main"], snapshot["docker_cache_from_refs"]
    assert_equal true, snapshot["docker_cache_import_ready"]
    assert_equal "h1+h2c-auto", snapshot["http_transport"]
    assert_equal true, snapshot["http2_enabled"]
    assert_equal 33_554_432, snapshot["oci_stream_through_min_bytes"]
    assert_equal "hit", snapshot["restore_result"]
    assert_equal "published", snapshot["save_result"]
    assert_equal "complete", snapshot["publish_status"]
    assert_equal "cache_session_summary.v2", snapshot.dig("session_summary", "schema")
    assert_equal "benchmark_cache_review.v1", snapshot.dig("cache_review", "schema_version")
    assert_equal "cache_miss_quality", snapshot.dig("cache_review", "primary_bottleneck")
    assert_equal "https://app.boringcache.com/workspaces/boringcache/benchmarks/cache/sessions/gh-123-1", snapshot["reporting_url"]
    assert_equal 256, snapshot.dig("storage_breakdown", "summary", "remote_cas_bytes")
    assert_equal 12, snapshot.dig("tool_outcomes", "gradle", "warm1", "executed_tasks")
    assert_equal "sccache", snapshot.dig("native_tool", "tool")
    assert_equal 94.6, snapshot.dig("native_tool", "hit_rate")
    assert_equal 25, snapshot.dig("slow_reason", "build_seconds")
    assert_equal 456, snapshot.dig("slow_reason", "paired_run_id")
    assert_equal ["cache_save_export_overhead"], snapshot.dig("slow_reason", "hypothesis_ids")
  end

  def test_auto_docker_artifact_keeps_docker_oci_adapter
    artifact = raw_boringcache_artifact.merge(
      "benchmark" => "posthog-auto"
    )
    artifact.delete("adapter")

    metrics = extract_strategy_metrics(artifact)

    assert_equal "docker", metrics[:mode]
    assert_equal "oci", metrics[:adapter]
  end

  def test_average_snapshot_carries_refs_and_flags_mixed_release_samples
    snapshots = [
      raw_snapshot("v1.12.86"),
      raw_snapshot("v1.12.86"),
      raw_snapshot("v1.12.85")
    ]

    averaged = average_snapshot(snapshots)

    assert_equal "v1.12.86", averaged.dig("product_refs", "cli_version")
    assert_equal false, averaged["product_refs_consistent"]
    assert_equal "metadata-only", averaged.dig("oci", "hydration_policy")
    assert_equal 152_000, averaged.dig("startup_prefetch", "duration_ms")
    assert_equal 100, averaged.dig("startup_prefetch", "concurrency")
    assert_equal "many_small_blobs_rtt_bound", averaged.dig("startup_prefetch", "concurrency_reason")
    assert_equal 25, averaged["cold_build_seconds"]
    assert_equal 3, averaged["warm1_build_seconds"]
    assert_equal 30, averaged["rolling_first_build_seconds"]
    assert_equal 4, averaged["rolling_warm_seconds"]
    assert_equal ["docker/action/fresh_runner_rerun"], averaged["launch_proof_paths"]
    assert_equal "boringcache/benchmarks", averaged["workspace"]
    assert_equal "h1+h2c-auto", averaged["http_transport"]
    assert_equal true, averaged["http2_enabled"]
    assert_equal 33_554_432, averaged["oci_stream_through_min_bytes"]
    assert_equal "cache_miss_quality", averaged.dig("cache_review", "primary_bottleneck")
    assert_equal 256, averaged.dig("storage_breakdown", "summary", "remote_cas_bytes")
    assert_equal 512, averaged.dig("storage_breakdown", "summary", "dependency_archive_bytes")
    assert_equal 12, averaged.dig("tool_outcomes", "gradle", "warm1", "executed_tasks")
    assert_equal "sccache", averaged.dig("native_tool", "tool")
    assert_equal 94.6, averaged.dig("native_tool", "hit_rate")
    assert_equal 25, averaged.dig("slow_reason", "build_seconds")
    assert_equal 3, averaged.dig("slow_reason", "sample_count")
    assert_equal ["cache_save_export_overhead"], averaged.dig("slow_reason", "hypothesis_ids")
    assert_equal 3, averaged.dig("slow_reason", "samples").length
  end

  def test_build_report_uses_current_lane_language
    entries = [
      {
        "name" => "Hugo",
        "lane" => "fresh",
        "lanes" => {
          "fresh" => lane_entry(lane: "fresh", scenario: "warm", label: "Warm Build"),
          "rolling" => lane_entry(
            lane: "rolling",
            scenario: "cold",
            label: "Commit Build",
            sample_count: 3,
            classification: {
              "reporting_reason" => "rolling_reseed",
              "rolling_reseed_count" => 1,
              "rolling_bootstrap_count" => 1
            },
            reporting: {
              "comparative" => false,
              "status" => "investigation_only",
              "reason" => "rolling_cache_bootstrap",
              "headline_label" => "Commit Build",
              "result_text" => "cache bootstrap 1/3",
              "note" => "Rolling cache was unavailable for 1/3 samples; those samples populated the rolling cache and are excluded from parity claims."
            }
          )
        }
      }
    ]

    report = build_report(entries, generated_at: "2026-05-06T10:00:00Z")

    assert_includes report, "## Fresh"
    assert_includes report, "## Rolling"
    assert_includes report, "Coverage: 1 benchmarks; fresh 1/1, rolling 1/1."
    assert_includes report, "Rows are latest complete same-commit pairs."
    assert_includes report, "| Benchmark | Metric | GitHub Actions Cache | BoringCache | Result | Storage |"
    assert_includes report, "| Hugo | Commit Build | 0m 10s | 0m 8s | cache bootstrap 1/3 | 200.00 B less (20.0%) |"
    refute_includes report, "BoringCache storage:"
    refute_includes report, "setup dominates"
    refute_includes report, "Caveat"
    refute_includes report, "Lane Coverage"
    refute_includes report, "Fresh Isolated"
    refute_includes report, "Rolling Historical"
    refute_includes report, "First Build"
    refute_includes report, "Storage Saved"
  end

  def test_strategy_metrics_infer_nx_mode_for_legacy_storybook_artifacts
    metrics = extract_strategy_metrics(
      "benchmark" => "storybook",
      "strategy" => "boringcache",
      "mode" => "boringcache",
      "runs" => {},
      "speed" => {},
      "cache" => { "storage_bytes" => 0 },
      "classification" => {}
    )

    assert_equal "nx", metrics[:mode]
    assert_equal "nx", metrics[:adapter]
  end

  def test_known_provider_run_exclusions_are_applied
    runs = [
      { "databaseId" => 26_157_635_153, "conclusion" => "success", "createdAt" => "2026-05-20T10:47:44Z" },
      { "databaseId" => 26_161_049_549, "conclusion" => "success", "createdAt" => "2026-05-20T11:58:55Z" }
    ]

    filtered = filter_excluded_provider_runs(repo: "boringcache/benchmark-posthog", runs: runs)

    assert_equal [26_161_049_549], filtered.map { |run| run["databaseId"] }
    assert_equal runs, filter_excluded_provider_runs(repo: "boringcache/benchmark-hugo", runs: runs)
  end

  def test_known_provider_lane_outliers_are_marked
    benchmark = benchmark_config(category: "rust").merge("benchmark" => "zed-sccache")

    reason = provider_lane_outlier_reason(benchmark: benchmark, strategy: "depot-cache", lane: "fresh")

    assert_includes reason, "cannot be reset"
    assert_nil provider_lane_outlier_reason(benchmark: benchmark, strategy: "depot-cache", lane: "rolling")
  end

  def test_capture_cmd_fails_when_descendant_keeps_output_pipe_open
    skip "fork is required to simulate an inherited output pipe" unless Process.respond_to?(:fork)

    with_constant(:CMD_OUTPUT_DRAIN_TIMEOUT_SECONDS, 0.1) do
      error = assert_raises(RuntimeError) do
        capture_cmd(RbConfig.ruby, "-e", "fork { sleep 30 }; exit!")
      end

      assert_includes error.message, "Command output pipes did not close"
    end
  end

  def test_benchmark_refresh_timeout_bounds_ruby_side_hangs
    with_constant(:BENCHMARK_REFRESH_TIMEOUT_SECONDS, 0.1) do
      error = assert_raises(RuntimeError) do
        with_benchmark_timeout({ "benchmark" => "immich" }) { sleep 5 }
      end

      assert_includes error.message, "Timed out refreshing immich"
    end
  end

  def test_provider_workflows_include_standard_and_optional_providers
    benchmark = benchmark_config(category: "go").merge(
      "workflow" => "zed-sccache-benchmark.yml",
      "extra_providers" => ["depot-cache"]
    )

    assert_equal(
      {
        "actions-cache" => "zed-sccache-benchmark.yml",
        "boringcache" => "zed-sccache-benchmark.yml",
        "depot-cache" => "zed-sccache-benchmark.yml"
      },
      provider_workflows_for(benchmark)
    )
    assert_equal "Depot Cache", provider_label("depot-cache")
    assert_equal "custom-cache", provider_label("custom-cache")

    docker_benchmark = benchmark_config(category: "docker").merge(
      "workflow" => "posthog-benchmark.yml"
    )
    assert_equal(
      {
        "actions-cache" => "posthog-benchmark.yml",
        "boringcache" => "posthog-benchmark.yml",
        "boringcache-auto" => "posthog-benchmark.yml"
      },
      provider_workflows_for(docker_benchmark)
    )
    assert_equal "BoringCache Auto", provider_label("boringcache-auto")
    assert_equal false, provider_storage_available?("boringcache-auto")
    assert_includes lane_artifact_names(benchmark_id: "posthog", strategy: "boringcache-auto", lane: "rolling"),
      "benchmark-posthog-auto-boringcache-rolling"
  end

  def test_provider_lane_payload_summarizes_samples
    snapshots = [
      pair_snapshot(
        run_id: "older-provider",
        created_at: "2026-05-20T10:00:00Z",
        seconds: 10,
        product_refs: PRODUCT_REFS,
        classification: { "reporting_mode" => "comparative" }
      ),
      pair_snapshot(
        run_id: "newer-provider",
        created_at: "2026-05-20T11:00:00Z",
        seconds: 20,
        product_refs: PRODUCT_REFS,
        classification: { "reporting_mode" => "comparative" }
      )
    ]

    payload = provider_lane_payload(
      lane: "rolling",
      runs: [{ "databaseId" => 1 }, { "databaseId" => 2 }, { "databaseId" => 3 }],
      unique_head_count: 3,
      snapshots: snapshots,
      storage_available: true
    )

    assert_equal "healthy", payload["state"]
    assert_equal 3, payload["successful_run_count"]
    assert_equal 2, payload["selected_sample_count"]
    assert_equal "newer-provider", payload["latest_run_id"]
    assert_equal "tool_elapsed_seconds", payload.dig("headline", "metric")
    assert_equal "Tool Elapsed", payload.dig("headline", "label")
    assert_equal 15, payload.dig("headline", "seconds")
    assert_equal 15, payload.dig("summary", "cold_seconds")
    assert_equal 15, payload.dig("summary", "scenario_seconds")
    assert_equal 15, payload.dig("summary", "tool_elapsed_seconds")
    assert_equal ["older-provider", "newer-provider"], payload["sample_run_ids"]
    assert_equal 2, payload["samples"].length

    missing_tool_elapsed = provider_lane_payload(
      lane: "fresh",
      runs: [{ "databaseId" => 1 }],
      unique_head_count: 1,
      snapshots: [
        pair_snapshot(
          run_id: "no-build-timing",
          created_at: "2026-05-20T12:00:00Z",
          seconds: 30,
          product_refs: PRODUCT_REFS,
          classification: { "reporting_mode" => "comparative" }
        ).merge(
          "cold_seconds" => nil,
          "warm_steady_seconds" => nil,
          "cold_build_seconds" => nil,
          "warm1_build_seconds" => nil,
          "run_total_seconds" => 10
        )
      ],
      storage_available: true
    )

    assert_equal "missing_tool_elapsed", missing_tool_elapsed["state"]
    refute missing_tool_elapsed.key?("headline")

    missing = provider_lane_payload(lane: "fresh", runs: [], unique_head_count: 0, snapshots: [], storage_available: false)

    assert_equal "missing_sample", missing["state"]
    assert_equal 0, missing["selected_sample_count"]
    assert_equal false, missing["storage_available"]
    refute missing.key?("summary")
  end

  def test_provider_lane_outlier_payload_excludes_headline_samples
    payload = provider_lane_outlier_payload(
      lane: "fresh",
      runs: [{ "databaseId" => 1 }, { "databaseId" => 2 }],
      unique_head_count: 2,
      storage_available: false,
      reason: "provider cache cannot be reset"
    )

    assert_equal "outlier", payload["state"]
    assert_equal "provider cache cannot be reset", payload["outlier_reason"]
    assert_equal 2, payload["successful_run_count"]
    assert_equal 0, payload["selected_sample_count"]
    assert_equal false, payload["storage_available"]
    refute payload.key?("headline")
    refute payload.key?("samples")
  end

  def test_runner_variance_filter_excludes_only_matching_native_tool_outlier
    providers = provider_matrix(
      "actions-cache" => [
        provider_native_snapshot(run_id: "actions", compiler_seconds: 37.475, hits: 2290, misses: 84, seconds: 2_131)
      ],
      "boringcache" => [
        provider_native_snapshot(run_id: "boringcache", compiler_seconds: 37.329, hits: 2290, misses: 84, seconds: 2_128)
      ],
      "depot-cache" => [
        provider_native_snapshot(run_id: "depot", compiler_seconds: 29.292, hits: 2289, misses: 85, timeouts: 1, seconds: 1_821)
      ]
    )

    filtered = apply_runner_variance_outlier_filter(providers)
    depot_lane = filtered.dig("depot-cache", "lanes", "rolling")

    assert_equal "missing_sample", depot_lane["state"]
    assert_equal 1, depot_lane["source_sample_count"]
    assert_equal 1, depot_lane["excluded_runner_variance_outlier_count"]
    assert_equal ["depot"], depot_lane["runner_variance_outliers"].map { |row| row["run_id"] }
    assert_equal "faster", depot_lane.dig("runner_variance_outliers", 0, "outlier_direction")
    assert_equal ["actions", "boringcache"], depot_lane.dig("runner_variance_outliers", 0, "peer_run_ids")
    assert_equal 1, filtered.dig("actions-cache", "lanes", "rolling", "selected_sample_count")
    assert_equal 1, filtered.dig("boringcache", "lanes", "rolling", "selected_sample_count")
    refute filtered.dig("actions-cache", "lanes", "rolling").key?("runner_variance_outliers")
    refute filtered.dig("boringcache", "lanes", "rolling").key?("runner_variance_outliers")
  end

  def test_runner_variance_filter_keeps_sample_when_cache_work_differs
    providers = provider_matrix(
      "actions-cache" => [
        provider_native_snapshot(run_id: "actions", compiler_seconds: 37.475, hits: 2290, misses: 84, seconds: 2_131)
      ],
      "boringcache" => [
        provider_native_snapshot(run_id: "boringcache", compiler_seconds: 37.329, hits: 2290, misses: 84, seconds: 2_128)
      ],
      "depot-cache" => [
        provider_native_snapshot(run_id: "depot", compiler_seconds: 29.292, hits: 2254, misses: 120, seconds: 1_821)
      ]
    )

    filtered = apply_runner_variance_outlier_filter(providers)
    depot_lane = filtered.dig("depot-cache", "lanes", "rolling")

    assert_equal "healthy", depot_lane["state"]
    assert_equal 1, depot_lane["selected_sample_count"]
    refute depot_lane.key?("runner_variance_outliers")
  end

  def test_runner_variance_filter_keeps_sample_when_headline_timing_is_not_distorted
    providers = provider_matrix(
      "actions-cache" => [
        provider_native_snapshot(run_id: "actions", compiler_seconds: 63.691, hits: 2296, misses: 3, seconds: 1_287)
      ],
      "boringcache" => [
        provider_native_snapshot(run_id: "boringcache", compiler_seconds: 68.374, hits: 2296, misses: 3, seconds: 1_293)
      ],
      "depot-cache" => [
        provider_native_snapshot(run_id: "depot", compiler_seconds: 47.146, hits: 2295, misses: 4, seconds: 1_353)
      ]
    )

    filtered = apply_runner_variance_outlier_filter(providers)
    depot_lane = filtered.dig("depot-cache", "lanes", "rolling")

    assert_equal "healthy", depot_lane["state"]
    assert_equal 1, depot_lane["selected_sample_count"]
    refute depot_lane.key?("runner_variance_outliers")
  end

  def test_runner_variance_filter_needs_two_comparable_peers
    providers = provider_matrix(
      "actions-cache" => [
        provider_native_snapshot(run_id: "actions", compiler_seconds: 37.475, seconds: 2_131)
      ],
      "depot-cache" => [
        provider_native_snapshot(run_id: "depot", compiler_seconds: 29.292, seconds: 1_821)
      ]
    )

    filtered = apply_runner_variance_outlier_filter(providers)

    assert_equal 1, filtered.dig("depot-cache", "lanes", "rolling", "selected_sample_count")
    refute filtered.dig("depot-cache", "lanes", "rolling").key?("runner_variance_outliers")
  end

  def test_runner_variance_filter_keeps_samples_when_peers_disagree
    providers = provider_matrix(
      "actions-cache" => [
        provider_native_snapshot(run_id: "actions", compiler_seconds: 32.0, seconds: 2_131)
      ],
      "boringcache" => [
        provider_native_snapshot(run_id: "boringcache", compiler_seconds: 44.0, seconds: 2_128)
      ],
      "depot-cache" => [
        provider_native_snapshot(run_id: "depot", compiler_seconds: 25.0, seconds: 1_821)
      ]
    )

    filtered = apply_runner_variance_outlier_filter(providers)

    filtered.each_value do |provider|
      lane = provider.dig("lanes", "rolling")
      assert_equal "healthy", lane["state"]
      assert_equal 1, lane["selected_sample_count"]
      refute lane.key?("runner_variance_outliers")
    end
  end

  def test_provider_snapshot_uses_build_time_and_strips_third_party_storage
    data = {
      run: {
        "databaseId" => 123,
        "url" => "https://github.com/boringcache/benchmark-zed/actions/runs/123",
        "headSha" => "feedface",
        "createdAt" => "2026-05-20T10:00:00Z"
      },
      run_total_seconds: 600,
      metrics: {
        cold_seconds: 420,
        cold_build_seconds: 360,
        cold_restore_or_setup_seconds: 60,
        warm1_seconds: nil,
        warm1_build_seconds: nil,
        warm1_restore_or_setup_seconds: nil,
        warm2_seconds: nil,
        warm_average_seconds: nil,
        rolling_first_build_seconds: 420,
        rolling_warm_seconds: nil,
        storage_bytes: 1_000,
        storage_source: "github-actions-cache-api-partial",
        storage_breakdown: { "total_bytes" => 1_000 },
        docker_cache_import_seconds: nil,
        docker_cache_export_seconds: nil,
        startup_prefetch: {},
        oci: {},
        classification: {},
        product_refs: {},
        product_refs_consistent: nil,
        slow_reason: {
          "cache_save_export_seconds" => 8,
          "post_cleanup_seconds" => 4
        }
      }
    }

    snapshot = provider_snapshot(data, strategy: "depot-cache")

    assert_equal 420, snapshot["scenario_seconds"]
    assert_equal "cold_seconds", snapshot["scenario_metric_source"]
    assert_equal 432, snapshot["tool_elapsed_seconds"]
    assert_equal(
      {
        "scenario_seconds" => 420,
        "cache_save_export_seconds" => 8,
        "post_cleanup_seconds" => 4
      },
      snapshot["tool_elapsed_components"]
    )
    assert_equal 600, snapshot["run_total_seconds"]
    assert_equal false, snapshot["storage_available"]
    assert_equal "Depot Cache storage is not available from benchmark artifacts.", snapshot["storage_note"]
    refute snapshot.key?("storage_bytes")
    refute snapshot.key?("storage_source")
    refute snapshot.key?("storage_breakdown")

    data[:metrics][:cold_seconds] = nil
    data[:metrics][:cold_build_seconds] = nil
    data[:metrics][:warm1_seconds] = nil
    data[:metrics][:warm1_build_seconds] = nil
    data[:metrics][:warm2_seconds] = nil
    data[:metrics][:warm_average_seconds] = nil
    no_build_snapshot = provider_snapshot(data, strategy: "buildbuddy-cache")

    refute no_build_snapshot.key?("scenario_seconds")
    refute no_build_snapshot.key?("scenario_metric_source")
    refute no_build_snapshot.key?("tool_elapsed_seconds")
    refute no_build_snapshot.key?("tool_elapsed_components")
    assert_equal 600, no_build_snapshot["run_total_seconds"]
  end

  def test_comparative_entries_exclude_actions_cache_bootstrap
    steady = paired_entry(
      ac_classification: { "reporting_mode" => "comparative" },
      bc_classification: { "reporting_mode" => "comparative" }
    )
    bootstrap = paired_entry(
      ac_classification: {
        "reporting_mode" => "investigation_only",
        "reporting_reason" => "rolling_cache_import_not_ok",
        "cache_import_status" => "actions_cache_miss"
      },
      bc_classification: { "reporting_mode" => "comparative" }
    )

    measured = comparative_entries([bootstrap, steady], lane: "rolling", category: "nodejs")

    assert_equal [steady], measured
  end

  def test_lane_average_uses_latest_product_cohort_before_bootstrap_filtering
    old_steady = lane_pair(
      run_id: "old-steady",
      created_at: "2026-05-01T10:00:00Z",
      cli_version: "v1.12.85",
      bc_classification: { "reporting_mode" => "comparative" },
      actions_seconds: 10,
      boringcache_seconds: 8
    )
    current_bootstrap = lane_pair(
      run_id: "current-bootstrap",
      created_at: "2026-05-02T10:00:00Z",
      cli_version: "v1.12.86",
      bc_classification: {
        "reporting_mode" => "investigation_only",
        "reporting_reason" => "rolling_reseed",
        "rolling_reseed_count" => 1,
        "rolling_bootstrap_count" => 1,
        "cache_import_status" => "proxy_unreadable"
      },
      actions_seconds: 10,
      boringcache_seconds: 30
    )

    averaged = average_lane_entries(
      [current_bootstrap, old_steady],
      benchmark: benchmark_config(category: "docker"),
      lane: "rolling"
    )

    assert_equal ["current-bootstrap-bc"], averaged.dig("comparison", "boringcache", "sample_run_ids")
    assert_equal "v1.12.86", averaged.dig("comparison", "boringcache", "product_refs", "cli_version")
    assert_equal false, averaged.dig("comparison", "reporting", "comparative")
    assert_equal "cache bootstrap", averaged["comparison"].dig("reporting", "result_text")
    assert_equal "latest_boringcache_product_refs", averaged.dig("comparison", "product_cohort", "basis")
    assert_equal 1, averaged.dig("comparison", "product_cohort", "excluded_sample_count")
  end

  def test_latest_pair_feed_stays_exact_while_window_averages
    current_pair = lane_pair(
      run_id: "current",
      created_at: "2026-05-03T10:00:00Z",
      cli_version: "v1.12.86",
      bc_classification: { "reporting_mode" => "comparative" },
      actions_seconds: 30,
      boringcache_seconds: 24
    )
    older_pair = lane_pair(
      run_id: "older",
      created_at: "2026-05-02T10:00:00Z",
      cli_version: "v1.12.86",
      bc_classification: { "reporting_mode" => "comparative" },
      actions_seconds: 10,
      boringcache_seconds: 8
    )

    latest = latest_lane_entry([current_pair, older_pair])
    window = average_lane_entries(
      [current_pair, older_pair],
      benchmark: benchmark_config(category: "docker"),
      lane: "fresh"
    )
    pair_point = pair_point_from_entry(current_pair)
    health = lane_health(
      benchmark: benchmark_config(category: "docker"),
      lane: "fresh",
      actions_runs: [{ "databaseId" => 1 }],
      boringcache_runs: [{ "databaseId" => 2 }],
      paired_head_count: 2,
      entries: [current_pair, older_pair]
    )

    assert_equal "current-ac", latest.dig("comparison", "actions_cache", "run_id")
    assert_equal 30, latest.dig("comparison", "actions_cache", "cold_seconds")
    assert_equal 20, window["before_seconds"]
    assert_equal 16, window["after_seconds"]
    assert_equal "benchmark_commit_pair", pair_point["point_type"]
    assert_equal "feedface", pair_point["head_sha"]
    assert_equal "current-ac", pair_point["actions_run_id"]
    assert_equal "current-bc", pair_point["boringcache_run_id"]
    assert_equal "healthy", health["state"]
    assert_equal 2, health["selected_pair_count"]
    assert_equal "feedface", health["latest_head_sha"]
  end

  def test_lane_average_never_uses_workflow_wall_time_as_headline
    entry = {
      "comparison" => {
        "pairing_head_sha" => "feedface",
        "pairing_head_shas" => ["feedface"],
        "actions_cache" => pair_snapshot(
          run_id: "actions",
          created_at: "2026-05-20T10:00:00Z",
          seconds: 80,
          product_refs: {},
          classification: { "reporting_mode" => "comparative" }
        ).merge(
          "cold_build_seconds" => 10,
          "warm1_build_seconds" => nil,
          "run_total_seconds" => 100
        ),
        "boringcache" => pair_snapshot(
          run_id: "boringcache",
          created_at: "2026-05-20T10:00:00Z",
          seconds: 90,
          product_refs: PRODUCT_REFS,
          classification: { "reporting_mode" => "comparative" }
        ).merge(
          "cold_build_seconds" => 20,
          "warm1_build_seconds" => nil,
          "run_total_seconds" => 50
        )
      }
    }

    averaged = average_lane_entries([entry], benchmark: benchmark_config(category: "docker"), lane: "fresh")

    assert_equal "Cold Build", averaged["headline_label"]
    assert_equal 80, averaged["before_seconds"]
    assert_equal 90, averaged["after_seconds"]
    assert_equal "0", averaged["faster"]
    assert_equal(-12.5, averaged.dig("comparison", "cold_improvement_pct"))
    assert_equal(-100.0, averaged.dig("comparison", "cold_build_improvement_pct"))
    refute averaged.fetch("comparison").key?("run_total_improvement_pct")
  end

  private

  def benchmark_config(category:)
    {
      "benchmark" => "hugo",
      "name" => "Hugo",
      "logo" => "hugo",
      "repo" => "gohugoio/hugo",
      "source_repo" => "boringcache/benchmark-hugo",
      "public" => true,
      "category" => category,
      "step" => "Docker build"
    }
  end

  def lane_pair(run_id:, created_at:, cli_version:, bc_classification:, actions_seconds:, boringcache_seconds:)
    {
      "comparison" => {
        "pairing_head_sha" => "feedface",
        "pairing_head_shas" => ["feedface"],
        "actions_cache" => pair_snapshot(
          run_id: "#{run_id}-ac",
          created_at: created_at,
          seconds: actions_seconds,
          product_refs: {},
          classification: { "reporting_mode" => "comparative" }
        ),
        "boringcache" => pair_snapshot(
          run_id: "#{run_id}-bc",
          created_at: created_at,
          seconds: boringcache_seconds,
          product_refs: PRODUCT_REFS.merge("cli_version" => cli_version),
          classification: bc_classification
        )
      }
    }
  end

  def pair_snapshot(run_id:, created_at:, seconds:, product_refs:, classification:)
    {
      "run_id" => run_id,
      "run_url" => "https://github.com/boringcache/benchmark-hugo/actions/runs/#{run_id}",
      "head_sha" => "feedface",
      "created_at" => created_at,
      "cold_seconds" => seconds,
      "cold_build_seconds" => seconds,
      "warm1_seconds" => seconds,
      "warm1_build_seconds" => seconds,
      "warm_average_seconds" => seconds,
      "run_total_seconds" => seconds,
      "storage_bytes" => 1_000,
      "storage_source" => "test",
      "classification" => classification,
      "product_refs" => product_refs,
      "workspace" => "boringcache/benchmarks",
      "mode" => "docker",
      "adapter" => "oci"
    }
  end

  def provider_matrix(samples_by_strategy, lane: "rolling")
    samples_by_strategy.each_with_object({}) do |(strategy, snapshots), acc|
      acc[strategy] = {
        "strategy" => strategy,
        "label" => provider_label(strategy),
        "workflow" => "#{strategy}.yml",
        "lanes" => {
          lane => provider_lane_payload(
            lane: lane,
            runs: Array.new(snapshots.length),
            unique_head_count: snapshots.map { |snapshot| snapshot["head_sha"] }.uniq.length,
            snapshots: snapshots,
            storage_available: provider_storage_available?(strategy)
          )
        }
      }
    end
  end

  def provider_native_snapshot(
    run_id:,
    compiler_seconds:,
    head_sha: "native-head",
    hits: 2290,
    misses: 84,
    requests: 2701,
    executed: 2382,
    non_cacheable: 310,
    hit_rate: 96.46,
    timeouts: 0,
    seconds: 2_100
  )
    {
      "run_id" => run_id,
      "run_url" => "https://github.com/boringcache/benchmark-zed/actions/runs/#{run_id}",
      "head_sha" => head_sha,
      "created_at" => "2026-05-28T05:58:00Z",
      "cold_seconds" => seconds,
      "cold_build_seconds" => seconds,
      "run_total_seconds" => seconds,
      "native_tool" => {
        "schema_version" => "native_tool_evidence.v1",
        "tool" => "sccache",
        "compile_requests" => requests,
        "compile_requests_executed" => executed,
        "cache_hits" => hits,
        "cache_misses" => misses,
        "hit_rate" => hit_rate,
        "hit_counts" => {
          "rust" => 1483,
          "c_cpp" => 666,
          "c" => hits - 1483 - 666
        },
        "miss_counts" => {
          "rust" => misses
        },
        "non_cacheable_calls" => non_cacheable,
        "non_cacheable_reasons" => {
          "crate-type" => 263,
          "-o" => 30,
          "-" => 10,
          "missing input" => 6,
          "missing emit" => 1
        },
        "average_compiler_seconds" => compiler_seconds,
        "cache_errors" => 0,
        "cache_read_errors" => 0,
        "cache_write_errors" => 0,
        "cache_timeouts" => timeouts
      }
    }
  end

  def paired_entry(ac_classification:, bc_classification:)
    {
      "comparison" => {
        "actions_cache" => { "classification" => ac_classification },
        "boringcache" => { "classification" => bc_classification }
      }
    }
  end

  def lane_entry(lane:, scenario:, label:, reporting: { "comparative" => true }, sample_count: 1, classification: {})
    {
      "lane" => lane,
      "name" => "Hugo",
      "headline_scenario" => scenario,
      "headline_label" => label,
      "before" => "0m 10s",
      "after" => "0m 8s",
      "before_seconds" => 10,
      "after_seconds" => 8,
      "comparison" => {
        "sample_count" => sample_count,
        "reporting" => reporting,
        "storage_saved_bytes" => 200,
        "storage_improvement_pct" => 20.0,
        "actions_cache" => {
          "cold_seconds" => 10,
          "warm1_seconds" => 10,
          "run_total_seconds" => 10
        },
        "boringcache" => {
          "cold_seconds" => 8,
          "warm1_seconds" => 8,
          "run_total_seconds" => 8,
          "storage_breakdown" => storage_breakdown_sample,
          "classification" => classification
        }
      }
    }
  end

  def raw_boringcache_artifact
    {
      "strategy" => "boringcache",
      "runs" => {
        "cold_seconds" => 30,
        "cold_build_seconds" => 25,
        "cold_restore_or_setup_seconds" => 5,
        "warm1_seconds" => 4,
        "warm1_build_seconds" => 3,
        "warm1_restore_or_setup_seconds" => 1,
        "rolling_first_build_seconds" => 30,
        "rolling_warm_seconds" => 4
      },
      "speed" => {
        "warm_average_seconds" => 4
      },
      "cache" => {
        "storage_bytes" => 1024,
        "storage_source" => "boringcache-check",
        "storage_breakdown" => storage_breakdown_sample,
        "workspace" => "boringcache/benchmarks",
        "tag" => "hugo-docker-main",
        "mode" => "docker"
      },
      "docker_cache" => {
        "import_seconds" => 0.5,
        "export_seconds" => 3.0,
        "from_refs" => ["cache:hugo-main"],
        "import_ready" => true
      },
      "http_transport" => "h1+h2c-auto",
      "http2_enabled" => true,
      "oci_stream_through_min_bytes" => 33_554_432,
      "oci" => {
        "hydration_policy" => "metadata-only",
        "new_blob_count" => 0
      },
      "classification" => {
        "sample_valid" => true,
        "reporting_mode" => "comparative",
        "publish_status" => "complete"
      },
      "product_refs" => PRODUCT_REFS,
      "launch_proof_paths" => ["docker/action/fresh_runner_rerun"],
      "run_uid" => "gh-123-1",
      "adapter" => "oci",
      "restore_result" => "hit",
      "save_result" => "published",
      "tool_outcomes" => tool_outcomes_sample,
      "native_tool" => native_tool_sample,
      "slow_reason" => slow_reason_sample,
      "cache_review" => cache_review_sample,
      "cache_session_summary" => {
        "schema" => "cache_session_summary.v2",
        "startup_prefetch" => {
          "startup_prefetch_duration_ms" => 152_000,
          "startup_prefetch_target_blobs" => 16_555,
          "startup_prefetch_target_bytes" => 865_049_699,
          "startup_prefetch_concurrency" => 100,
          "startup_prefetch_initial_concurrency" => 20,
          "startup_prefetch_final_concurrency" => 100,
          "startup_prefetch_max_observed_concurrency" => 100,
          "startup_prefetch_concurrency_reason" => "many_small_blobs_rtt_bound",
          "startup_prefetch_retries" => 1,
          "startup_prefetch_failures" => 0
        }
      },
      "reporting_url" => "https://app.boringcache.com/workspaces/boringcache/benchmarks/cache/sessions/gh-123-1"
    }
  end

  def raw_snapshot(cli_version)
    refs = PRODUCT_REFS.merge("cli_version" => cli_version)
    {
      "run_id" => cli_version,
      "run_url" => "https://github.com/boringcache/benchmark-hugo/actions/runs/#{cli_version}",
      "head_sha" => cli_version,
      "created_at" => cli_version == "v1.12.85" ? "2026-05-03T10:00:00Z" : "2026-05-04T10:00:00Z",
      "cold_seconds" => 30,
      "cold_build_seconds" => 25,
      "cold_restore_or_setup_seconds" => 5,
      "warm1_seconds" => 4,
      "warm1_build_seconds" => 3,
      "warm1_restore_or_setup_seconds" => 1,
      "rolling_first_build_seconds" => 30,
      "rolling_warm_seconds" => 4,
      "storage_bytes" => 1024,
      "product_refs" => refs,
      "launch_proof_paths" => ["docker/action/fresh_runner_rerun"],
      "workspace" => "boringcache/benchmarks",
      "http_transport" => "h1+h2c-auto",
      "http2_enabled" => true,
      "oci_stream_through_min_bytes" => 33_554_432,
      "oci" => {
        "hydration_policy" => "metadata-only",
        "new_blob_count" => 0
      },
      "storage_breakdown" => storage_breakdown_sample,
      "tool_outcomes" => tool_outcomes_sample,
      "native_tool" => native_tool_sample,
      "startup_prefetch" => {
        "duration_ms" => 152_000,
        "concurrency" => 100,
        "concurrency_reason" => "many_small_blobs_rtt_bound"
      },
      "cache_review" => cache_review_sample,
      "slow_reason" => slow_reason_sample
    }
  end

  def storage_breakdown_sample
    {
      "total_bytes" => 1024,
      "summary" => {
        "remote_cas_bytes" => 256,
        "dependency_archive_bytes" => 512,
        "tool_runtime_archive_bytes" => 256,
        "unknown_bytes" => 0
      },
      "components" => [
        {
          "tag" => "hugo-docker-main-remote",
          "storage_mode" => "cas",
          "component_type" => "remote_cas",
          "component_label" => "remote CAS",
          "bytes" => 256
        },
        {
          "tag" => "hugo-docker-main-deps",
          "storage_mode" => "archive",
          "component_type" => "dependency_archive",
          "component_label" => "dependency archive",
          "bytes" => 512
        },
        {
          "tag" => "hugo-docker-main-mise-node",
          "storage_mode" => "archive",
          "component_type" => "tool_runtime_archive",
          "component_label" => "tool runtime archive",
          "bytes" => 256
        }
      ]
    }
  end

  def tool_outcomes_sample
    {
      "gradle" => {
        "local_build_cache_policy" => "default",
        "warm1" => {
          "actionable_tasks" => 51,
          "executed_tasks" => 12,
          "from_cache_tasks" => 34,
          "up_to_date_tasks" => 5
        }
      },
      "warnings" => ["warm1_executed_tasks_high"]
    }
  end

  def native_tool_sample
    {
      "schema_version" => "native_tool_evidence.v1",
      "tool" => "sccache",
      "cache_hits" => 2173,
      "cache_misses" => 124,
      "hit_rate" => 94.6
    }
  end

  def slow_reason_sample
    {
      "schema_version" => "benchmark_slow_reason.v1",
      "benchmark" => "hugo",
      "strategy" => "boringcache",
      "lane" => "rolling",
      "run_uid" => "gh-123-1",
      "paired_run_id" => nil,
      "build_seconds" => 25,
      "setup_seconds" => 5,
      "post_cleanup_seconds" => nil,
      "cache_restore_seconds" => 0.5,
      "cache_save_export_seconds" => 3.0,
      "hit_count" => 100,
      "miss_count" => 39,
      "hit_rate" => 71.9,
      "prior_cache_state" => "usable_import",
      "new_blob_bytes" => 0,
      "issue_candidates" => [],
      "hypotheses" => [
        {
          "id" => "cache_save_export_overhead",
          "confidence" => "medium",
          "summary" => "Cache save/export time is visible in the sample."
        }
      ],
      "hypothesis_ids" => ["cache_save_export_overhead"]
    }
  end

  def cache_review_sample
    {
      "schema_version" => "benchmark_cache_review.v1",
      "primary_bottleneck" => "cache_miss_quality",
      "customer_summary" => "Remote cache missed enough work to matter."
    }
  end

  def with_constant(name, value)
    original = Object.const_get(name)
    Object.send(:remove_const, name)
    Object.const_set(name, value)
    yield
  ensure
    Object.send(:remove_const, name) if Object.const_defined?(name, false)
    Object.const_set(name, original)
  end
end
