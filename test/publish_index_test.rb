# frozen_string_literal: true

require "minitest/autorun"
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
    snapshot = strategy_snapshot(
      run: {
        "databaseId" => 123,
        "url" => "https://github.com/boringcache/benchmark-hugo/actions/runs/123",
        "headSha" => "feedface",
        "createdAt" => "2026-05-04T10:00:00Z"
      },
      run_total_seconds: 42.0,
      metrics: metrics
    )

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
    assert_equal "https://app.boringcache.com/workspaces/boringcache/benchmarks/cache/sessions/gh-123-1", snapshot["reporting_url"]
    assert_equal 256, snapshot.dig("storage_breakdown", "summary", "remote_cas_bytes")
    assert_equal 12, snapshot.dig("tool_outcomes", "gradle", "warm1", "executed_tasks")
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
    assert_equal 256, averaged.dig("storage_breakdown", "summary", "remote_cas_bytes")
    assert_equal 512, averaged.dig("storage_breakdown", "summary", "dependency_archive_bytes")
    assert_equal 12, averaged.dig("tool_outcomes", "gradle", "warm1", "executed_tasks")
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

    assert_includes report, "### Fresh"
    assert_includes report, "### Rolling"
    assert_includes report, "| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |"
    assert_includes report, "| Hugo | Commit Build | 0m 10s | 0m 8s | cache bootstrap 1/3 | 200.00 B (20.0%) | tiny run; setup dominates; BC storage: remote CAS 256.00 B, deps archive 512.00 B, runtime archive 256.00 B; 3 paired samples; cache bootstrap 1/3; Rolling cache was unavailable"
    assert_includes report, "BC storage: remote CAS 256.00 B, deps archive 512.00 B, runtime archive 256.00 B"
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
      "warm1_seconds" => seconds,
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
      "startup_prefetch" => {
        "duration_ms" => 152_000,
        "concurrency" => 100,
        "concurrency_reason" => "many_small_blobs_rtt_bound"
      }
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
end
