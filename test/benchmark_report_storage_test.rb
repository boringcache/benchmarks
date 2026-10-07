# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "socket"
require "tmpdir"

class BenchmarkReportStorageTest < Minitest::Test
  CANONICAL = File.expand_path("../scripts/canonical/benchmark-report.py", __dir__)

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
      assert_equal ["check", "boringcache/benchmark-example", "cache-one,cache-two", "--no-git", "--no-platform", "--exact", "--json"], JSON.parse(File.read(invocation_path))

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
      body = JSON.generate("actions_caches" => [
        { "key" => "gradle-example-rolling-main", "size_in_bytes" => 100 },
        { "key" => "gradle-example-rolling-main", "size_in_bytes" => 250 },
        { "key" => "gradle-example-rolling-main-older", "size_in_bytes" => 900 }
      ])
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

      assert_equal 350, payload.dig("cache", "storage_bytes")
      assert_equal "github-actions-cache-api", payload.dig("cache", "storage_source")
      assert_equal "gradle-example-rolling-main", payload.dig("cache", "storage_breakdown", "key")
      assert_includes requests.pop, "key=gradle-example-rolling-main"
    end
  ensure
    server&.close
    server_thread&.join
  end

  private

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
      "python3", CANONICAL, "phase",
      "--benchmark", "example", "--strategy", strategy,
      "--lane", "rolling", "--phase", "commit", "--mode", "gradle",
      "--build-seconds", "20",
      "--output-dir", output_dir,
      *(evidence ? ["--evidence", evidence_path] : []),
      *extra_args
    )
    assert status.success?, "reporter failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"

    JSON.parse(File.read(File.join(output_dir, "example-#{strategy}-rolling-commit.json")))
  end

  def summarize(dir)
    phase_dir = File.join(dir, "output")
    output_dir = File.join(dir, "lanes")
    stdout, stderr, status = Open3.capture3(
      "python3", CANONICAL, "summarize",
      "--title", "Example", "--input-dir", phase_dir, "--output-dir", output_dir
    )
    assert status.success?, "reporter failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"

    JSON.parse(File.read(File.join(output_dir, "example-boringcache-rolling.json")))
  end
end
