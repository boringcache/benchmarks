# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class BoringcacheDockerProductRunTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/canonical/assert-boringcache-docker-product-run.sh", __dir__)

  def test_accepts_cli_harvested_vertex_spans
    status, output = run_contract(
      "operation" => "cache_session_summary",
      "buildkit" => {
        "vertex_spans" => {
          "schema_version" => "buildkit_vertex_spans.v1",
          "total_spans" => 5,
          "executed_count" => 2,
          "cached_count" => 3,
          "error_count" => 0
        }
      }
    )

    assert status.success?, output
    assert_includes output, "Managed Docker product path verified"
    assert_includes output, "total=5"
    assert_includes output, "summary_bytes="
  end

  def test_rejects_setup_only_or_raw_docker_evidence
    status, output = run_contract(
      "operation" => "cache_session_summary",
      "buildkit" => {}
    )

    refute status.success?
    assert_includes output, "missing buildkit.vertex_spans evidence"
    assert_includes output, "setup-only plus raw Docker is not the managed product path"
  end

  def test_uses_the_last_session_summary
    status, output = run_contract(
      { "operation" => "cache_session_summary", "buildkit" => {} },
      {
        "operation" => "cache_session_summary",
        "summary" => {
          "buildkit" => {
            "vertex_spans" => {
              "schema_version" => "buildkit_vertex_spans.v1",
              "total_spans" => 1,
              "executed_count" => 1,
              "cached_count" => 0,
              "error_count" => 0
            }
          }
        }
      }
    )

    assert status.success?, output
    assert_includes output, "total=1"
  end

  def test_rejects_a_summary_larger_than_the_ingestion_contract
    status, output = run_contract(
      "operation" => "cache_session_summary",
      "buildkit" => {
        "vertex_spans" => {
          "schema_version" => "buildkit_vertex_spans.v1",
          "total_spans" => 1,
          "executed_count" => 1,
          "cached_count" => 0,
          "error_count" => 0
        }
      },
      "unbounded" => "x" * 70_000
    )

    refute status.success?
    assert_includes output, "Rails accepts at most 65536 bytes"
  end

  private

  def run_contract(*records)
    Dir.mktmpdir("boringcache-product-run") do |dir|
      path = File.join(dir, "observability.jsonl")
      File.write(path, records.map { |record| JSON.generate(record) }.join("\n") << "\n")
      stdout, stderr, status = Open3.capture3("bash", SCRIPT, path)
      return [status, stdout + stderr]
    end
  end
end
