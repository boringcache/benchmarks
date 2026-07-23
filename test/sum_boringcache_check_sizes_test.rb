# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class SumBoringcacheCheckSizesTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/canonical/sum-boringcache-check-sizes.sh", __dir__)

  def setup
    skip "canonical helper currently requires Bash 4 associative arrays" if bash_major_version < 4
  end

  def test_native_kv_rows_are_measured_without_archive_inspection
    check_payload = {
      results: [
        {
          tag: "maven-remote",
          requested_tag: "maven-remote",
          status: "hit",
          cache_type: "kv",
          compressed_size: 123,
          kv_entry_count: 7,
          kv_total_size: 123
        },
        {
          tag: "maven-deps",
          requested_tag: "maven-deps",
          status: "hit",
          cache_type: "cache_entry",
          cache_entry_id: "entry-1",
          compressed_size: 456
        }
      ]
    }
    inspect_payloads = {
      "entry-1" => {
        entry: {
          id: "entry-1",
          primary_tag: "maven-deps",
          storage_mode: "archive",
          stored_size_bytes: 456,
          archive_size: 456,
          blob_total_size_bytes: 0
        }
      }
    }

    result = run_helper(check_payload, inspect_payloads)

    assert result[:status].success?, result[:stderr]
    assert_equal "579\n", result[:stdout]
    assert_equal ["entry-1"], result[:inspect_calls]
    assert_equal 579, result[:breakdown].fetch("total_bytes")
    assert_equal 123, result[:breakdown].dig("summary", "remote_kv_bytes")
    assert_equal 456, result[:breakdown].dig("summary", "dependency_archive_bytes")
    assert_equal %w[remote_kv dependency_archive], result[:breakdown].fetch("components").map { |row| row.fetch("component_type") }
  end

  def test_inspect_enrichment_failure_falls_back_to_check_metadata
    check_payload = {
      results: [
        {
          tag: "deps",
          requested_tag: "deps",
          status: "hit",
          cache_type: "cache_entry",
          cache_entry_id: "missing-entry",
          compressed_size: 789
        }
      ]
    }

    result = run_helper(check_payload, {})

    assert result[:status].success?, result[:stderr]
    assert_equal "789\n", result[:stdout]
    assert_includes result[:stderr], "using check metadata"
    assert_equal 789, result[:breakdown].dig("summary", "unknown_bytes")
    assert_equal "missing-entry", result[:breakdown].dig("components", 0, "cache_entry_id")
  end

  private

  def bash_major_version
    stdout, = Open3.capture3("bash", "-c", 'printf "%s" "${BASH_VERSINFO[0]}"')
    stdout.to_i
  end

  def run_helper(check_payload, inspect_payloads)
    Dir.mktmpdir("bc-check-sizes") do |dir|
      bin_dir = File.join(dir, "bin")
      Dir.mkdir(bin_dir)
      breakdown_path = File.join(dir, "breakdown.json")
      check_path = File.join(dir, "check.json")
      inspect_path = File.join(dir, "inspect.json")
      inspect_log_path = File.join(dir, "inspect.log")
      File.write(check_path, JSON.generate(check_payload))
      File.write(inspect_path, JSON.generate(inspect_payloads))
      fake_cli = File.join(bin_dir, "boringcache")
      File.write(fake_cli, <<~'SH')
        #!/usr/bin/env bash
        set -euo pipefail
        case "${1:-}" in
          check)
            cat "$FAKE_CHECK_PATH"
            ;;
          inspect)
            target="${3:-}"
            printf '%s\n' "$target" >> "$FAKE_INSPECT_LOG_PATH"
            jq -e --arg target "$target" '.[$target] // empty' "$FAKE_INSPECT_PATH"
            ;;
          *)
            exit 64
            ;;
        esac
      SH
      File.chmod(0o755, fake_cli)

      env = {
        "PATH" => "#{bin_dir}:#{ENV.fetch("PATH")}",
        "BORINGCACHE_STORAGE_BREAKDOWN_PATH" => breakdown_path,
        "FAKE_CHECK_PATH" => check_path,
        "FAKE_INSPECT_PATH" => inspect_path,
        "FAKE_INSPECT_LOG_PATH" => inspect_log_path
      }
      stdout, stderr, status = Open3.capture3(env, SCRIPT, "boringcache/benchmark", "maven-remote,maven-deps")

      {
        stdout: stdout,
        stderr: stderr,
        status: status,
        breakdown: File.exist?(breakdown_path) ? JSON.parse(File.read(breakdown_path)) : {},
        inspect_calls: File.exist?(inspect_log_path) ? File.readlines(inspect_log_path, chomp: true) : []
      }
    end
  end
end
