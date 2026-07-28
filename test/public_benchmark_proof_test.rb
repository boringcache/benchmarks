# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "rbconfig"
require "tmpdir"

class PublicBenchmarkProofTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/check-public-benchmark-proof.rb", __dir__)

  PRODUCT_REFS = {
    "cli_version" => "v1.13.13",
    "action_ref" => "boringcache/one@v1",
    "action_sha" => "c5c6f8439a19eccc1d6dc421cfb20899d7cbb614",
    "web_revision" => "bb4230e0"
  }.freeze

  def test_current_public_benchmark_index_has_product_proof_refs
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, SCRIPT)

    assert status.success?, "public proof guardrail failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    assert_includes stdout, "public benchmark proof guardrails passed"
  end

  def test_public_valid_action_backed_proof_requires_action_sha
    payload = index_payload(product_refs: PRODUCT_REFS.reject { |key, _| key == "action_sha" })

    stdout, stderr, status = run_script_with_payload(payload)

    refute status.success?, "guardrail unexpectedly passed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    assert_includes stderr, "hugo/fresh: missing product_refs.action_sha for Action-backed public proof"
  end

  def test_public_valid_action_backed_proof_requires_action_ref
    payload = index_payload(product_refs: PRODUCT_REFS.reject { |key, _| key == "action_ref" })

    stdout, stderr, status = run_script_with_payload(payload)

    refute status.success?, "guardrail unexpectedly passed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    assert_includes stderr, "hugo/fresh: missing product_refs.action_ref for Action-backed public proof"
  end

  def test_public_valid_cli_only_proof_does_not_invent_action_participation
    product_refs = PRODUCT_REFS.reject { |key, _| %w[action_ref action_sha].include?(key) }
    payload = index_payload(product_refs: product_refs)

    stdout, stderr, status = run_script_with_payload(payload)

    assert status.success?, "CLI-only guardrail failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    assert_includes stdout, "public benchmark proof guardrails passed"
  end

  def test_import_failure_cannot_be_comparative_public_proof
    payload = index_payload(
      classification: {
        "sample_valid" => true,
        "reporting_mode" => "comparative",
        "cache_import_status" => "proxy_unreadable"
      }
    )

    stdout, stderr, status = run_script_with_payload(payload)

    refute status.success?, "guardrail unexpectedly passed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    assert_includes stderr, "cache_import_status=proxy_unreadable cannot be comparative public proof"
  end

  private

  def run_script_with_payload(payload)
    Dir.mktmpdir("public-proof") do |dir|
      path = File.join(dir, "index.json")
      File.write(path, JSON.generate(payload))
      return Open3.capture3(RbConfig.ruby, SCRIPT, path)
    end
  end

  def index_payload(product_refs: PRODUCT_REFS, classification: nil)
    classification ||= {
      "sample_valid" => true,
      "reporting_mode" => "comparative",
      "cache_import_status" => "ok"
    }

    {
      "entries" => [
        {
          "benchmark" => "hugo",
          "public" => true,
          "lanes" => {
            "fresh" => {
              "comparison" => {
                "boringcache" => {
                  "classification" => classification,
                  "product_refs" => product_refs,
                  "product_refs_consistent" => true
                }
              }
            }
          }
        }
      ]
    }
  end
end
