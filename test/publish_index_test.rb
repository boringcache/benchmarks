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
    assert_equal({ "schema" => "cache_session_summary.v2" }, snapshot["session_summary"])
    assert_equal "https://app.boringcache.com/workspaces/boringcache/benchmarks/cache/sessions/gh-123-1", snapshot["reporting_url"]
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
    assert_equal 25, averaged["cold_build_seconds"]
    assert_equal 3, averaged["warm1_build_seconds"]
    assert_equal 30, averaged["rolling_first_build_seconds"]
    assert_equal 4, averaged["rolling_warm_seconds"]
    assert_equal ["docker/action/fresh_runner_rerun"], averaged["launch_proof_paths"]
    assert_equal "boringcache/benchmarks", averaged["workspace"]
    assert_equal "h1+h2c-auto", averaged["http_transport"]
    assert_equal true, averaged["http2_enabled"]
    assert_equal 33_554_432, averaged["oci_stream_through_min_bytes"]
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
              "note" => "Rolling cache was unavailable for 1/3 BoringCache samples; those samples populated the rolling cache and are excluded from parity claims."
            }
          )
        }
      }
    ]

    report = build_report(entries, generated_at: "2026-05-06T10:00:00Z")

    assert_includes report, "### Fresh"
    assert_includes report, "### Rolling"
    assert_includes report, "| Benchmark | Metric | actions/cache | BoringCache | Result | Storage Delta | Notes |"
    assert_includes report, "| Hugo | Commit Build | 0m 10s | 0m 8s | cache bootstrap 1/3 | 200.00 B (20.0%) | tiny run; setup dominates; 3 paired samples; BC cache bootstrap 1/3; Rolling cache was unavailable"
    refute_includes report, "Fresh Isolated"
    refute_includes report, "Rolling Historical"
    refute_includes report, "First Build"
    refute_includes report, "Storage Saved"
  end

  private

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
      "cache_session_summary" => {
        "schema" => "cache_session_summary.v2"
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
      }
    }
  end
end
