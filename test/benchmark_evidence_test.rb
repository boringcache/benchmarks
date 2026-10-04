# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "base64"
require_relative "../scripts/benchmark-evidence"

class BenchmarkEvidenceTest < Minitest::Test
  class GitHub
    attr_reader :requests

    def initialize(expired: false, unavailable_attempt: nil, empty_logs: false, no_jobs: false)
      @requests = []
      @expired = expired
      @unavailable_attempt = unavailable_attempt
      @empty_logs = empty_logs
      @no_jobs = no_jobs
    end

    def api(path)
      @requests << path
      run = {"id" => 42, "head_sha" => "a" * 40, "run_attempt" => 2,
        "updated_at" => "2026-10-02T12:00:00Z", "status" => "completed", "path" => ".github/workflows/build.yml"}
      case path
      when %r{/contents/} then {"content" => Base64.strict_encode64("name: Build\n")}
      when %r{/commits/} then {"sha" => "a" * 40}
      when %r{/attempts/(\d+)\z} then run.merge("run_attempt" => Regexp.last_match(1).to_i)
      else run
      end
    end

    def pages(path, key)
      @requests << path
      if key == "jobs"
        return [] if @no_jobs
        attempt = path[%r{/attempts/(\d+)/}, 1].to_i
        [{"id" => 100 + attempt, "run_id" => 42, "run_attempt" => attempt}]
      else
        return [] if @no_jobs
        [{"id" => 99, "name" => "phase", "expired" => @expired}]
      end
    end

    def download(path, target)
      @requests << path
      if path.include?("/attempts/#{@unavailable_attempt}/")
        raise BenchmarkCases::Error, "Logs expired"
      end
      contents = @empty_logs && path.end_with?("/logs") ? "PK\x05\x06" + "\x00" * 18 : "download from #{path}\n"
      File.binwrite(target, contents)
    end
  end

  def with_export(**options)
    Dir.mktmpdir("benchmark-evidence-") do |directory|
      target = File.join(directory, "bundle")
      github = GitHub.new(**options)
      result = BenchmarkEvidence.export(repository: "example/workload", run_id: 42, directory: target, github: github)
      yield target, result, github
    end
  end

  def test_exports_all_attempts_and_verifies_the_scoped_inventory
    with_export do |target, result, github|
      assert_equal "complete", result["state"]
      assert_equal 11, result["verified_files"]
      assert_includes github.requests, "repos/example/workload/actions/runs/42/attempts/1/logs"
      assert_includes github.requests, "repos/example/workload/actions/runs/42/attempts/2/logs"
      assert_equal result, BenchmarkEvidence.verify(target)
    end
  end

  def test_missing_attempt_logs_and_expired_artifacts_remain_partial
    with_export(expired: true, unavailable_attempt: 1) do |_, result, _|
      assert_equal "partial", result["state"]
      assert_includes result["missing_files"], "attempts/1/logs.zip"
      assert_includes result["missing_files"], "artifacts/99.zip"
      assert_equal 2, result["gaps"].length
    end
  end

  def test_valid_empty_log_archives_are_retained_for_runs_with_no_jobs
    with_export(empty_logs: true, no_jobs: true) do |target, result, _|
      assert_equal "complete", result.fetch("state")
      path = File.join(target, "attempts/1/logs.zip")
      assert BenchmarkEvidence.empty_zip?(path)
      BenchmarkEvidence.verify_zip(path)
      File.binwrite(path, "PK\x05\x06" + "\x00" * 17 + "\x01")
      assert_raises(BenchmarkCases::Error) { BenchmarkEvidence.verify_zip(path) }
    end
  end

  def test_empty_log_archives_with_jobs_remain_partial
    with_export(empty_logs: true) do |target, result, _|
      assert_equal "partial", result.fetch("state")
      assert_equal "Jobs exist but the log archive has no entries", result.fetch("gaps").first.fetch("reason")
      manifest = JSON.parse(File.read(File.join(target, "manifest.json")))
      assert_equal 22, manifest.dig("files", "attempts/1/logs.zip", "bytes")
    end
  end

  def test_detects_changed_bytes_and_refuses_an_existing_export_destination
    with_export do |target, _, github|
      File.write(File.join(target, "workflow.yml"), "changed\n")
      assert_raises(BenchmarkCases::Error) { BenchmarkEvidence.verify(target) }
      assert_raises(BenchmarkCases::Error) do
        BenchmarkEvidence.export(repository: "example/workload", run_id: 42, directory: target, github: github)
      end
    end
  end

  def test_digest_integrity_does_not_replace_job_inventory_checks
    with_export do |target, _, _|
      path = File.join(target, "attempts", "1", "jobs.json")
      jobs = JSON.parse(File.read(path))
      jobs["jobs"][0]["id"] = 999
      manifest_path = File.join(target, "manifest.json")
      manifest = JSON.parse(File.read(manifest_path))
      BenchmarkEvidence.retain_json(target, "attempts/1/jobs.json", jobs, manifest)
      BenchmarkCases.write_json(manifest_path, manifest)
      error = assert_raises(BenchmarkCases::Error) { BenchmarkEvidence.verify(target) }
      assert_includes error.message, "Incomplete job inventory"
    end
  end

  def test_rejects_evidence_symlinks_outside_the_bundle
    with_export do |target, _, _|
      path = File.join(target, "workflow.yml")
      outside = File.join(File.dirname(target), "outside.yml")
      FileUtils.mv(path, outside)
      File.symlink(outside, path)
      error = assert_raises(BenchmarkCases::Error) { BenchmarkEvidence.verify(target) }
      assert_includes error.message, "unsafe evidence file"
    end
  end
end
