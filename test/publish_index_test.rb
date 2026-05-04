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
    assert_equal ["docker/action/fresh_runner_rerun"], snapshot["launch_proof_paths"]
    assert_equal "boringcache/benchmarks", snapshot["workspace"]
    assert_equal "hugo-docker-main", snapshot["cache_tag"]
    assert_equal "gh-123-1", snapshot["run_uid"]
    assert_equal "docker", snapshot["mode"]
    assert_equal "oci", snapshot["adapter"]
    assert_equal ["cache:hugo-main"], snapshot["docker_cache_from_refs"]
    assert_equal true, snapshot["docker_cache_import_ready"]
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
    assert_equal ["docker/action/fresh_runner_rerun"], averaged["launch_proof_paths"]
    assert_equal "boringcache/benchmarks", averaged["workspace"]
  end

  private

  def raw_boringcache_artifact
    {
      "strategy" => "boringcache",
      "runs" => {
        "cold_seconds" => 30,
        "warm1_seconds" => 4
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
      "warm1_seconds" => 4,
      "storage_bytes" => 1024,
      "product_refs" => refs,
      "launch_proof_paths" => ["docker/action/fresh_runner_rerun"],
      "workspace" => "boringcache/benchmarks",
      "oci" => {
        "hydration_policy" => "metadata-only",
        "new_blob_count" => 0
      }
    }
  end
end
