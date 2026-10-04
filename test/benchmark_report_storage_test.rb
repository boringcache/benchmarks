require "rbconfig"
# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "minitest/mock"
require "open3"
require "socket"
require "tmpdir"
require_relative "../scripts/canonical/benchmark-report"

class BenchmarkReportStorageTest < Minitest::Test
  CANONICAL = File.expand_path("../scripts/canonical/benchmark-report.rb", __dir__)

  def test_phase_verification_does_not_claim_every_case_check_has_run
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "benchmark-context.json"), JSON.generate(
        "comparison" => {"timed_scope" => "Restore and compile"},
        "verification" => ["Verify cold output", "Verify changed-source output"]
      ))
      env = {"BENCHMARK_SERIES_ID" => "screening", "BENCHMARK_SAMPLE" => "1"}
      payload = write_phase(dir, strategy: "actions-cache", evidence: false, extra_args: ["--verified-output"], env: env)
      assert_equal true, payload.dig("verification", "passed")
      assert_equal ["Output verification completed before recording this phase"], payload.dig("verification", "checks")
      assert_equal ["Verify cold output", "Verify changed-source output"], payload.dig("verification", "declared_checks")
    end
  end

  def test_phase_preserves_the_product_trust_decision
    Dir.mktmpdir do |dir|
      evidence = action_evidence
      decision = {"status" => "restore_only", "requested_policy" => "restore", "resolved_policy" => "restore", "write_allowed" => false}
      evidence.fetch("phases").fetch("restore")["trust_state"] = decision
      File.write(File.join(dir, "action-evidence.json"), JSON.generate(evidence))
      payload = write_phase(dir, strategy: "actions-cache")
      assert_equal decision, payload.dig("action", "trust_state")
    end
  end

  def test_boringcache_storage_uses_exact_resolved_tags_and_deduplicates_entries
    Dir.mktmpdir do |dir|
      evidence_path = File.join(dir, "action-evidence.json")
      check_path = File.join(dir, "check.json")
      invocation_path = File.join(dir, "check-invocation.json")
      bin_dir = File.join(dir, "bin")
      Dir.mkdir(bin_dir)
      File.write(evidence_path, JSON.generate(action_evidence))
      File.write(check_path, JSON.generate(
        "results" => [
          { "status" => "hit", "tag" => "cache-one", "cache_entry_id" => "entry-one", "compressed_size" => 150 },
          { "status" => "hit", "tag" => "cache-one-alias", "cache_entry_id" => "entry-one", "compressed_size" => 100 },
          { "status" => "hit", "tag" => "cache-two", "cache_entry_id" => "entry-two", "kv_total_size" => 50, "compressed_size" => 12 },
          { "status" => "miss", "tag" => "cache-miss", "compressed_size" => 500 }
        ]
      ))
      write_fake_boringcache(File.join(bin_dir, "boringcache"))

      payload = write_phase(
        dir,
        env: {
          "PATH" => "#{bin_dir}:#{ENV.fetch("PATH")}",
          "FAKE_CHECK_PATH" => check_path,
          "FAKE_CHECK_INVOCATION_PATH" => invocation_path
        }
      )

      assert_equal 200, payload.dig("cache", "storage_bytes")
      assert_equal "boringcache-check", payload.dig("cache", "storage_source")
      assert_equal "boringcache/benchmark-example", payload.dig("cache", "workspace")
      assert_equal ["cache-one", "cache-two"], payload.dig("cache", "storage_breakdown", "tags")
      assert_equal ["check", "boringcache/benchmark-example", "cache-one,cache-two", "--no-git", "--no-platform", "--json"], JSON.parse(File.read(invocation_path))

      lane = summarize(dir)
      assert_equal 200, lane.dig("cache", "storage_bytes")
      assert_equal "boringcache-check", lane.dig("cache", "storage_source")
    end
  end

  def test_boringcache_storage_is_unmeasured_when_the_probe_fails
    Dir.mktmpdir do |dir|
      bin_dir = File.join(dir, "bin")
      Dir.mkdir(bin_dir)
      failing_cli = File.join(bin_dir, "boringcache")
      File.write(failing_cli, "#!/usr/bin/env bash\nexit 1\n")
      File.chmod(0o755, failing_cli)
      evidence_path = File.join(dir, "action-evidence.json")
      File.write(evidence_path, JSON.generate(action_evidence))

      payload = write_phase(dir, env: { "PATH" => "#{bin_dir}:#{ENV.fetch("PATH")}" })

      assert_nil payload.dig("cache", "storage_bytes")
      assert_nil payload.dig("cache", "storage_source")
    end
  end

  def test_boringcache_storage_does_not_report_a_partial_probe_as_the_selected_total
    Dir.mktmpdir do |dir|
      bin_dir = File.join(dir, "bin")
      Dir.mkdir(bin_dir)
      check_path = File.join(dir, "check.json")
      invocation_path = File.join(dir, "check-invocation.json")
      File.write(check_path, JSON.generate("results" => [
        {"status" => "hit", "requested_tag" => "cache-one", "cache_entry_id" => "entry-one", "kv_total_size" => 200},
        {"status" => "hit", "requested_tag" => "cache-two", "cache_entry_id" => "entry-two"}
      ]))
      write_fake_boringcache(File.join(bin_dir, "boringcache"))
      payload = write_phase(dir, env: {"PATH" => "#{bin_dir}:#{ENV.fetch('PATH')}",
        "FAKE_CHECK_PATH" => check_path, "FAKE_CHECK_INVOCATION_PATH" => invocation_path})

      assert_nil payload.dig("cache", "storage_bytes")
      assert_nil payload.dig("cache", "storage_source")
      assert_equal false, payload.dig("cache", "storage_breakdown", "complete")
      assert_equal 200, payload.dig("cache", "storage_breakdown", "measured_bytes")
      assert_equal ["cache-two"], payload.dig("cache", "storage_breakdown", "unmeasured_tags")
      assert_equal JSON.parse(File.read(check_path)).fetch("results"), payload.dig("cache", "storage_breakdown", "observations")
    end
  end

  def test_archive_storage_does_not_use_an_unrelated_zero_byte_kv_observation
    Dir.mktmpdir do |dir|
      check_path = File.join(dir, "check.json")
      bin_dir = File.join(dir, "bin")
      Dir.mkdir(bin_dir)
      File.write(check_path, JSON.generate("results" => [
        {"status" => "hit", "requested_tag" => "archive-tag", "cache_type" => "cache_entry",
         "cache_entry_id" => "archive-one", "kv_total_size" => 0, "compressed_size" => 75}
      ]))
      write_fake_boringcache(File.join(bin_dir, "boringcache"))
      payload = write_phase(dir, evidence: false,
        extra_args: ["--workspace", "boringcache/benchmark-direct", "--cache-tag", "archive-tag"],
        env: {"PATH" => "#{bin_dir}:#{ENV.fetch('PATH')}", "FAKE_CHECK_PATH" => check_path,
          "FAKE_CHECK_INVOCATION_PATH" => File.join(dir, "invocation.json")})

      assert_equal 75, payload.dig("cache", "storage_bytes")
      assert_equal true, payload.dig("cache", "storage_breakdown", "complete")
    end
  end

  def test_storage_zero_requires_an_explicit_zero_byte_measurement
    Dir.mktmpdir do |dir|
      check_path = File.join(dir, "check.json")
      bin_dir = File.join(dir, "bin")
      Dir.mkdir(bin_dir)
      File.write(check_path, JSON.generate("results" => [
        {"status" => "hit", "requested_tag" => "empty-tag", "cache_type" => "kv", "kv_total_size" => 0}
      ]))
      write_fake_boringcache(File.join(bin_dir, "boringcache"))
      payload = write_phase(dir, evidence: false,
        extra_args: ["--workspace", "boringcache/benchmark-direct", "--cache-tag", "empty-tag"],
        env: {"PATH" => "#{bin_dir}:#{ENV.fetch('PATH')}", "FAKE_CHECK_PATH" => check_path,
          "FAKE_CHECK_INVOCATION_PATH" => File.join(dir, "invocation.json")})

      assert_equal 0, payload.dig("cache", "storage_bytes")
      assert_equal "boringcache-check", payload.dig("cache", "storage_source")
      assert_equal [], payload.dig("cache", "storage_breakdown", "unmeasured_tags")
    end
  end

  def test_boringcache_storage_uses_explicit_cache_identity_without_action_evidence
    Dir.mktmpdir do |dir|
      check_path = File.join(dir, "check.json")
      invocation_path = File.join(dir, "check-invocation.json")
      bin_dir = File.join(dir, "bin")
      Dir.mkdir(bin_dir)
      File.write(check_path, JSON.generate("results" => [
        { "status" => "hit", "tag" => "direct-tag", "compressed_size" => 75 }
      ]))
      write_fake_boringcache(File.join(bin_dir, "boringcache"))

      payload = write_phase(
        dir,
        evidence: false,
        extra_args: ["--workspace", "boringcache/benchmark-direct", "--cache-tag", "direct-tag"],
        env: {
          "PATH" => "#{bin_dir}:#{ENV.fetch("PATH")}",
          "FAKE_CHECK_PATH" => check_path,
          "FAKE_CHECK_INVOCATION_PATH" => invocation_path
        }
      )

      assert_equal 75, payload.dig("cache", "storage_bytes")
      assert_equal "boringcache-check", payload.dig("cache", "storage_source")
      assert_equal "boringcache/benchmark-direct", payload.dig("cache", "workspace")
    end
  end

  def test_actions_cache_storage_uses_only_the_requested_cache_key
    entries = [
      {"id" => 1, "key" => "gradle-example-rolling-main", "size_in_bytes" => 100},
      {"id" => 2, "key" => "gradle-example-rolling-main", "size_in_bytes" => 250},
      {"id" => 3, "key" => "gradle-example-rolling-main-older", "size_in_bytes" => 900}
    ]
    with_actions_cache_api(entries) do |payload, request|
      assert_equal 350, payload.dig("cache", "storage_bytes")
      assert_equal "github-actions-cache-api", payload.dig("cache", "storage_source")
      assert_equal "gradle-example-rolling-main", payload.dig("cache", "storage_breakdown", "key")
      assert_equal true, payload.dig("cache", "storage_breakdown", "complete")
      assert_equal entries.take(2), payload.dig("cache", "storage_breakdown", "observations")
      assert_includes request, "key=gradle-example-rolling-main"
    end
  end

  def test_actions_cache_storage_keeps_a_partial_measurement_unqualified
    [nil, -1, "unknown"].each do |missing_size|
      entries = [
        {"id" => 1, "key" => "gradle-example-rolling-main", "size_in_bytes" => 100},
        {"id" => 2, "key" => "gradle-example-rolling-main", "size_in_bytes" => missing_size}
      ]
      with_actions_cache_api(entries) do |payload, _request|
        assert_nil payload.dig("cache", "storage_bytes")
        assert_nil payload.dig("cache", "storage_source")
        assert_equal false, payload.dig("cache", "storage_breakdown", "complete")
        assert_equal 100, payload.dig("cache", "storage_breakdown", "measured_bytes")
        assert_equal entries, payload.dig("cache", "storage_breakdown", "observations")
      end
    end
  end

  def test_actions_cache_storage_distinguishes_a_measured_zero_from_no_matching_cache
    with_actions_cache_api([{"key" => "gradle-example-rolling-main", "size_in_bytes" => 0}]) do |payload, _request|
      assert_equal 0, payload.dig("cache", "storage_bytes")
      assert_equal "github-actions-cache-api", payload.dig("cache", "storage_source")
      assert_equal true, payload.dig("cache", "storage_breakdown", "complete")
    end
    with_actions_cache_api([{"key" => "another-cache", "size_in_bytes" => 0}]) do |payload, _request|
      assert_nil payload.dig("cache", "storage_bytes")
      assert_nil payload.dig("cache", "storage_source")
      assert_equal false, payload.dig("cache", "storage_breakdown", "complete")
      assert_equal [], payload.dig("cache", "storage_breakdown", "observations")
    end
  end

  def test_actions_cache_pagination_does_not_forward_credentials_to_another_origin
    original = ENV.to_h.slice("GITHUB_REPOSITORY", "GITHUB_TOKEN", "GITHUB_API_URL")
    ENV.update("GITHUB_REPOSITORY" => "boringcache/benchmark-example", "GITHUB_TOKEN" => "test-token",
      "GITHUB_API_URL" => "http://127.0.0.1:8000")
    response = Net::HTTPOK.new("1.1", "200", "OK")
    response.body = JSON.generate("actions_caches" => [{"key" => "selected", "size_in_bytes" => 100}])
    response["Link"] = '<http://127.0.0.1:9000/next>; rel="next"'
    requests = []
    Net::HTTP.stub(:start, ->(*args, **_options) { requests << args; response }) do
      assert_nil BenchmarkReport.actions_storage("selected")
    end
    assert_equal [["127.0.0.1", 8000]], requests
  ensure
    %w[GITHUB_REPOSITORY GITHUB_TOKEN GITHUB_API_URL].each { |key| ENV[key] = original[key] }
  end

  private

  def with_actions_cache_api(entries)
    server = TCPServer.new("127.0.0.1", 0)
    port = server.addr[1]
    requests = Queue.new
    server_thread = Thread.new do
      socket = server.accept
      request = socket.gets
      requests << request
      while (header = socket.gets)
        break if header == "\r\n"
      end
      body = JSON.generate("actions_caches" => entries)
      socket.write("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: #{body.bytesize}\r\n\r\n#{body}")
      socket.close
    end

    Dir.mktmpdir do |dir|
      payload = write_phase(
        dir,
        strategy: "actions-cache",
        extra_args: ["--storage-key", "gradle-example-rolling-main"],
        env: {
          "GITHUB_REPOSITORY" => "boringcache/benchmark-example",
          "GITHUB_TOKEN" => "test-token",
          "GITHUB_API_URL" => "http://127.0.0.1:#{port}"
        }
      )

      yield payload, requests.pop
    end
  ensure
    server&.close
    server_thread&.join
  end

  def action_evidence
    {
      "schema_version" => "boringcache_one_evidence.v1",
      "phases" => {
        "restore" => {
          "workspace" => "boringcache/benchmark-example",
          "cache_tag" => "cache-one",
          "resolved_tags" => ["cache-one", "cache-two", "cache-one"]
        }
      }
    }
  end

  def write_fake_boringcache(path)
    File.write(path, <<~'SH')
      #!/usr/bin/env bash
      set -euo pipefail
      printf '%s\n' "$(printf '%s\n' "$@" | jq -R . | jq -s .)" > "$FAKE_CHECK_INVOCATION_PATH"
      for argument in "$@"; do
        if [ "$argument" = "--exact" ]; then
          exit 2
        fi
      done
      cat "$FAKE_CHECK_PATH"
    SH
    File.chmod(0o755, path)
  end

  def write_phase(dir, strategy: "boringcache", evidence: true, extra_args: [], env: {})
    evidence_path = File.join(dir, "action-evidence.json")
    File.write(evidence_path, JSON.generate(action_evidence)) if evidence && !File.exist?(evidence_path)
    output_dir = File.join(dir, "output")
    stdout, stderr, status = Open3.capture3(
      env,
      RbConfig.ruby, CANONICAL, "phase",
      "--benchmark", "example", "--strategy", strategy,
      "--source-repository", "example/upstream", "--source-sha", "a" * 40,
      "--lane", "rolling", "--phase", "commit", "--mode", "gradle",
      "--build-seconds", "20",
      "--output-dir", output_dir,
      *(evidence ? ["--evidence", evidence_path] : []),
      *extra_args,
      chdir: dir
    )
    assert status.success?, "reporter failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"

    JSON.parse(File.read(File.join(output_dir, "example-#{strategy}-rolling-commit.json")))
  end

  def summarize(dir)
    phase_dir = File.join(dir, "output")
    output_dir = File.join(dir, "lanes")
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby, CANONICAL, "summarize",
      "--title", "Example", "--input-dir", phase_dir, "--output-dir", output_dir
    )
    assert status.success?, "reporter failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"

    JSON.parse(File.read(File.join(output_dir, "example-boringcache-rolling.json")))
  end
end
