# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class LaunchProofTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  SCRIPT = File.join(ROOT, "scripts/launch-proof.rb")

  PRODUCT_REFS = {
    "action_ref" => "boringcache/one@v1",
    "action_sha" => "0123456789abcdef0123456789abcdef01234567",
    "cli_version" => "v1.12.86",
    "web_revision" => "89abcdef0123456789abcdef0123456789abcdef",
    "api_url" => "https://app.boringcache.com"
  }.freeze

  def test_artifact_launch_proof_path_satisfies_required_fields
    Dir.mktmpdir do |dir|
      artifacts_dir = File.join(dir, "artifacts")
      matrix_path = File.join(dir, "matrix.json")

      write_json(File.join(artifacts_dir, "archive.json"), benchmark_artifact)
      write_json(matrix_path, matrix_for("archive", "cli", "fresh_cold", archive_required_fields))

      stdout, stderr, status = run_launch_proof("--artifacts", artifacts_dir, "--matrix", matrix_path)

      assert status.success?, stderr
      assert_includes stdout, "launch proof passed"
    end
  end

  def test_matrix_reports_matching_path_that_lacks_required_fields
    Dir.mktmpdir do |dir|
      artifacts_dir = File.join(dir, "artifacts")
      matrix_path = File.join(dir, "matrix.json")

      proof_path = archive_proof_path.merge("reporting_url" => nil)
      write_json(File.join(artifacts_dir, "archive.json"), benchmark_artifact(proof_path: proof_path))
      write_json(matrix_path, matrix_for("archive", "cli", "fresh_cold", archive_required_fields))

      _stdout, stderr, status = run_launch_proof("--artifacts", artifacts_dir, "--matrix", matrix_path)

      refute status.success?
      assert_includes stderr, "missing launch proof path archive/cli/fresh_cold with required fields"
      assert_includes stderr, "reporting_url"
    end
  end

  def test_external_evidence_requires_product_refs
    Dir.mktmpdir do |dir|
      artifacts_dir = File.join(dir, "artifacts")
      matrix_path = File.join(dir, "matrix.json")
      evidence_path = File.join(dir, "evidence.json")

      write_json(File.join(artifacts_dir, "archive.json"), benchmark_artifact(proof_paths: []))
      write_json(matrix_path, matrix_for("scope_trust", "action", "pr_restore_reads_base_default", scope_required_fields))
      write_json(evidence_path, "evidence" => [scope_evidence_without_product_refs])

      _stdout, stderr, status = run_launch_proof(
        "--artifacts", artifacts_dir,
        "--matrix", matrix_path,
        "--evidence", evidence_path
      )

      refute status.success?
      assert_includes stderr, "missing product_refs or release ref fields"
    end
  end

  def test_docker_required_transport_fields_can_come_from_session_summary
    Dir.mktmpdir do |dir|
      artifacts_dir = File.join(dir, "artifacts")
      matrix_path = File.join(dir, "matrix.json")

      write_json(File.join(artifacts_dir, "docker.json"), docker_benchmark_artifact)
      write_json(matrix_path, matrix_for("docker", "action", "fresh_runner_rerun", docker_required_fields))

      stdout, stderr, status = run_launch_proof("--artifacts", artifacts_dir, "--matrix", matrix_path)

      assert status.success?, stderr
      assert_includes stdout, "launch proof passed"
    end
  end

  private

  def run_launch_proof(*args)
    Open3.capture3("ruby", SCRIPT, *args)
  end

  def write_json(path, payload)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(payload))
  end

  def matrix_for(tool, surface, scenario, required_fields)
    {
      "schema" => "test.launch_proof_matrix",
      "default_required_fields" => %w[
        product_refs.action_ref
        product_refs.cli_version
        product_refs.action_sha
        product_refs.web_revision
        product_refs.api_url
      ],
      "paths" => [
        {
          "tool" => tool,
          "surface" => surface,
          "required_scenarios" => [scenario],
          "required_fields" => required_fields
        }
      ]
    }
  end

  def benchmark_artifact(proof_path: archive_proof_path, proof_paths: nil)
    {
      "strategy" => "boringcache",
      "benchmark" => "launch-fixture",
      "lane" => "fresh",
      "category" => "archive",
      "cache_mode" => "archive",
      "product_refs" => PRODUCT_REFS,
      "classification" => {
        "sample_valid" => true,
        "reporting_mode" => "valid"
      },
      "cache_session_summary" => {
        "schema" => "cache_session_summary.v2",
        "hit" => true
      },
      "launch_proof_paths" => proof_paths || [proof_path]
    }
  end

  def archive_proof_path
    {
      "tool" => "archive",
      "surface" => "cli",
      "scenario" => "fresh_cold",
      "workspace" => "acme/web",
      "cache_tag" => "archive-main",
      "run_uid" => "run-123",
      "mode" => "archive",
      "adapter" => "archive",
      "restore_result" => "miss",
      "save_result" => "published",
      "publish_status" => "complete",
      "session_summary" => {
        "schema" => "cache_session_summary.v2"
      },
      "reporting_url" => "https://app.boringcache.com/workspaces/acme/web/cache/sessions/run-123"
    }
  end

  def archive_required_fields
    %w[
      workspace
      cache_tag
      run_uid
      mode
      adapter
      restore_result
      save_result
      publish_status
      session_summary
      reporting_url
    ]
  end

  def docker_benchmark_artifact
    benchmark_artifact(proof_paths: [docker_proof_path]).merge(
      "category" => "docker",
      "cache_mode" => "docker",
      "oci" => {
        "hydration_policy" => "metadata-only",
        "new_blob_count" => 0,
        "upload_requested_blobs" => 12,
        "upload_already_present" => 12
      },
      "cache_session_summary" => {
        "schema" => "cache_session_summary.v2",
        "proxy" => {
          "hydration_policy" => "metadata-only",
          "http_transport" => "h1+h2c-auto",
          "http2_enabled" => true,
          "oci_stream_through_min_bytes" => 33_554_432
        }
      }
    )
  end

  def docker_proof_path
    {
      "tool" => "docker",
      "surface" => "action",
      "scenario" => "fresh_runner_rerun",
      "workspace" => "acme/web",
      "cache_tag" => "docker-main",
      "run_uid" => "run-123",
      "mode" => "docker",
      "adapter" => "oci",
      "docker_cache_from_refs" => ["cache:docker-main"],
      "docker_cache_import_ready" => true,
      "restore_result" => "hit",
      "save_result" => "published",
      "new_blob_count" => 0,
      "remote_fetches" => 1,
      "publish_status" => "complete",
      "session_summary" => {
        "schema" => "cache_session_summary.v2"
      },
      "reporting_url" => "https://app.boringcache.com/workspaces/acme/web/cache/sessions/run-123"
    }
  end

  def docker_required_fields
    %w[
      workspace
      cache_tag
      run_uid
      mode
      adapter
      docker_cache_from_refs
      docker_cache_import_ready
      hydration_policy
      http_transport
      http2_enabled
      oci_stream_through_min_bytes
      restore_result
      save_result
      new_blob_count
      remote_fetches
      publish_status
      session_summary
      reporting_url
    ]
  end

  def scope_required_fields
    %w[
      workspace
      run_uid
      event_name
      read_scopes
      write_scope
      restore_token_role
      save_token_role
      permission_result
      session_summary
      reporting_url
    ]
  end

  def scope_evidence_without_product_refs
    {
      "tool" => "scope_trust",
      "surface" => "action",
      "scenario" => "pr_restore_reads_base_default",
      "status" => "pass",
      "workspace" => "acme/web",
      "run_uid" => "pr-123",
      "event_name" => "pull_request",
      "read_scopes" => ["base", "default"],
      "write_scope" => nil,
      "restore_token_role" => "restore",
      "save_token_role" => "none",
      "permission_result" => "restore_only",
      "session_summary" => {
        "schema" => "cache_session_summary.v2"
      },
      "reporting_url" => "https://app.boringcache.com/workspaces/acme/web/cache/sessions/pr-123"
    }
  end
end
