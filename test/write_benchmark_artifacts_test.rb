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
    assert_equal "cache_import_not_ok", payload.dig("classification", "rolling_reseed_kind")
  end

  private

  def write_artifact(*extra_args)
    Dir.mktmpdir("bc-artifacts") do |dir|
      command = [
        SCRIPT,
        "--benchmark", "hugo",
        "--strategy", "boringcache",
        "--lane", "rolling",
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
      JSON.parse(File.read(File.join(dir, "hugo-boringcache-rolling.json")))
    end
  end
end
