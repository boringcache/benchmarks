# frozen_string_literal: true

require_relative "benchmark-cases"
require "tempfile"

module BenchmarkEvidence
  class GitHub
    def api(path)
      JSON.parse(BenchmarkCases.command("gh", "api", path))
    end

    def pages(path, key)
      pages = JSON.parse(BenchmarkCases.command("gh", "api", path, "--paginate", "--slurp"))
      items = pages.flat_map { |page| page.fetch(key) }
      total = pages.first.fetch("total_count")
      raise BenchmarkCases::Error, "Incomplete GitHub #{key} inventory: expected #{total}, received #{items.length}" unless items.length == total
      items
    end

    def download(path, target)
      Tempfile.create("evidence-download") do |errors|
        pid = Process.spawn("gh", "api", path, out: target, err: errors)
        Process.wait(pid)
        raise BenchmarkCases::Error, "GitHub download unavailable for #{path}" unless $?.success?
      end
      raise BenchmarkCases::Error, "GitHub returned an empty download for #{path}" if File.size(target).zero?
      if target.end_with?(".zip")
        BenchmarkEvidence.verify_zip(target)
      end
      File.chmod(0o600, target)
    end
  end

  def self.empty_zip?(path)
    File.size(path) == 22 && File.binread(path) == "PK\x05\x06" + "\x00" * 18
  end

  def self.verify_zip(path)
    return if empty_zip?(path)
    BenchmarkCases.command("unzip", "-tqq", path)
  end

  def self.export(repository:, run_id:, directory:, github: GitHub.new)
    raise BenchmarkCases::Error, "Invalid repository" unless repository.match?(%r{\A[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\z})
    raise BenchmarkCases::Error, "Invalid run ID" unless run_id.is_a?(Integer) && run_id.positive?
    raise BenchmarkCases::Error, "Evidence destination already exists" if File.exist?(directory)
    FileUtils.mkdir_p(directory, mode: 0o700)
    base = "repos/#{repository}/actions/runs/#{run_id}"
    run = github.api(base)
    manifest = {"schema_version" => 1, "repository" => repository, "run_id" => run_id,
                "run_url" => "https://github.com/#{repository}/actions/runs/#{run_id}", "source_sha" => run.fetch("head_sha"),
                "exported_at" => Time.now.utc.iso8601, "scope" => "run, attempts, jobs, logs, artifacts, commit, workflow",
                "state" => "exporting", "attempts" => [], "artifacts" => [], "gaps" => [], "files" => {}}
    retain_json(directory, "run.json", run, manifest)
    attempts = run.fetch("run_attempt")
    raise BenchmarkCases::Error, "Invalid run attempt count" unless attempts.is_a?(Integer) && attempts.positive?
    (1..attempts).each do |attempt|
      prefix = "attempts/#{attempt}"
      attempt_path = "#{base}/attempts/#{attempt}"
      begin
        current = github.api(attempt_path)
        jobs = github.pages("#{attempt_path}/jobs?per_page=100", "jobs")
        retain_json(directory, "#{prefix}/run.json", current, manifest)
        retain_json(directory, "#{prefix}/jobs.json", {"total_count" => jobs.length, "jobs" => jobs}, manifest)
        manifest["attempts"] << {"attempt" => attempt, "job_ids" => jobs.map { |job| job.fetch("id") }}
        retain_download(directory, "#{prefix}/logs.zip", "#{attempt_path}/logs", github, manifest)
        if jobs.any? && manifest.fetch("files").key?("#{prefix}/logs.zip") && empty_zip?(File.join(directory, "#{prefix}/logs.zip"))
          manifest["gaps"] << {"resource" => "#{prefix}/logs.zip", "reason" => "Jobs exist but the log archive has no entries"}
        end
      rescue BenchmarkCases::Error => error
        manifest["gaps"] << {"resource" => "#{prefix}/metadata", "reason" => error.message}
      end
    end
    begin
      artifacts = github.pages("#{base}/artifacts?per_page=100", "artifacts")
      retain_json(directory, "artifacts.json", {"total_count" => artifacts.length, "artifacts" => artifacts}, manifest)
      artifacts.each do |artifact|
        id = artifact.fetch("id")
        manifest["artifacts"] << artifact.slice("id", "name", "expired", "digest", "size_in_bytes", "expires_at", "created_at")
        relative = "artifacts/#{id}.zip"
        if artifact["expired"]
          manifest["gaps"] << {"resource" => relative, "reason" => "expired"}
          next
        end
        retain_download(directory, relative, "repos/#{repository}/actions/artifacts/#{id}/zip", github, manifest)
        digest = artifact["digest"]
        local = manifest["files"][relative]
        if local && digest && digest.start_with?("sha256:") && local.fetch("sha256") != digest.delete_prefix("sha256:")
          manifest["gaps"] << {"resource" => relative, "reason" => "GitHub artifact digest differs from downloaded ZIP"}
        end
      end
    rescue BenchmarkCases::Error => error
      manifest["gaps"] << {"resource" => "artifacts.json", "reason" => error.message}
    end
    begin
      retain_json(directory, "commit.json", github.api("repos/#{repository}/commits/#{run.fetch('head_sha')}"), manifest)
      path = run.fetch("path").split("@").first
      source = github.api("repos/#{repository}/contents/#{path}?ref=#{run.fetch('head_sha')}")
      require "base64"
      retain_bytes(directory, "workflow.yml", Base64.decode64(source.fetch("content")), manifest)
    rescue BenchmarkCases::Error => error
      manifest["gaps"] << {"resource" => "workflow.yml", "reason" => error.message}
    end
    latest = github.api(base)
    if latest.values_at("run_attempt", "updated_at", "status") != run.values_at("run_attempt", "updated_at", "status")
      manifest["gaps"] << {"resource" => "run.json", "reason" => "run changed during export"}
    end
    manifest["gaps"] << {"resource" => "run.json", "reason" => "run is not completed"} unless run["status"] == "completed"
    manifest["state"] = manifest.fetch("gaps").empty? ? "complete" : "partial"
    BenchmarkCases.write_json(File.join(directory, "manifest.json"), manifest)
    File.chmod(0o600, File.join(directory, "manifest.json"))
    verify(directory)
  rescue StandardError => error
    if manifest
      manifest["state"] = "partial"
      manifest["gaps"] << {"resource" => "export", "reason" => error.message}
      BenchmarkCases.write_json(File.join(directory, "manifest.json"), manifest)
    end
    raise
  end

  def self.retain_bytes(directory, relative, data, manifest)
    target = File.join(directory, relative)
    FileUtils.mkdir_p(File.dirname(target), mode: 0o700)
    File.write(target, data, mode: "wb", perm: 0o600)
    manifest["files"][relative] = {"sha256" => Digest::SHA256.file(target).hexdigest, "bytes" => File.size(target)}
  end

  def self.retain_json(directory, relative, value, manifest)
    retain_bytes(directory, relative, JSON.pretty_generate(value) + "\n", manifest)
  end

  def self.retain_download(directory, relative, endpoint, github, manifest)
    target = File.join(directory, relative)
    FileUtils.mkdir_p(File.dirname(target), mode: 0o700)
    github.download(endpoint, target)
    manifest["files"][relative] = {"sha256" => Digest::SHA256.file(target).hexdigest, "bytes" => File.size(target)}
  rescue BenchmarkCases::Error => error
    manifest["gaps"] << {"resource" => relative, "reason" => error.message}
  end

  def self.verify(directory)
    root = File.realpath(directory)
    manifest_path = File.join(root, "manifest.json")
    raise BenchmarkCases::Error, "Unsafe evidence manifest" unless File.realpath(manifest_path).start_with?(root + "/")
    manifest = JSON.parse(File.read(manifest_path))
    errors = []
    manifest.fetch("files").each do |relative, record|
      path = File.expand_path(relative, root)
      unless path.start_with?(root + "/") && File.file?(path) && File.realpath(path).start_with?(root + "/")
        errors << "Missing or unsafe evidence file: #{relative}"
        next
      end
      errors << "Evidence checksum mismatch: #{relative}" unless Digest::SHA256.file(path).hexdigest == record.fetch("sha256") && File.size(path) == record.fetch("bytes")
    end
    raise BenchmarkCases::Error, errors.join("\n") unless errors.empty?
    required = %w[run.json artifacts.json commit.json workflow.yml]
    raise BenchmarkCases::Error, "Evidence manifest has no run.json" unless manifest.fetch("files").key?("run.json")
    run = JSON.parse(File.read(File.join(root, "run.json")))
    errors << "Evidence run identity differs from manifest" unless run.fetch("id") == manifest.fetch("run_id") && run.fetch("head_sha") == manifest.fetch("source_sha")
    (1..run.fetch("run_attempt")).each do |attempt|
      required.concat(["attempts/#{attempt}/run.json", "attempts/#{attempt}/jobs.json", "attempts/#{attempt}/logs.zip"])
      attempt_path = "attempts/#{attempt}/run.json"
      jobs_path = "attempts/#{attempt}/jobs.json"
      next unless manifest.fetch("files").key?(attempt_path) && manifest.fetch("files").key?(jobs_path)
      current = JSON.parse(File.read(File.join(root, attempt_path)))
      errors << "Evidence attempt #{attempt} identity differs from the run" unless current.values_at("id", "run_attempt", "head_sha") == [run.fetch("id"), attempt, run.fetch("head_sha")]
      jobs = JSON.parse(File.read(File.join(root, jobs_path)))
      job_ids = jobs.fetch("jobs").map { |job| job.fetch("id") }
      recorded = manifest.fetch("attempts").find { |entry| entry.fetch("attempt") == attempt }
      unless jobs.fetch("total_count") == job_ids.length && job_ids.uniq == job_ids && recorded && recorded.fetch("job_ids").sort == job_ids.sort
        errors << "Incomplete job inventory for attempt #{attempt}"
      end
      jobs.fetch("jobs").each do |job|
        if job["run_id"] && job["run_id"] != run.fetch("id") || job["run_attempt"] && job["run_attempt"] != attempt
          errors << "Job #{job.fetch('id')} belongs to another run or attempt"
        end
      end
    end
    artifacts_path = File.join(root, "artifacts.json")
    if manifest.fetch("files").key?("artifacts.json")
      artifacts = JSON.parse(File.read(artifacts_path))
      errors << "Incomplete artifact inventory" unless artifacts.fetch("total_count") == artifacts.fetch("artifacts").length
      listed = artifacts.fetch("artifacts").map { |artifact| artifact.fetch("id") }.sort
      errors << "Artifact manifest differs from inventory" unless listed == manifest.fetch("artifacts").map { |artifact| artifact.fetch("id") }.sort && listed.uniq == listed
      artifacts.fetch("artifacts").each { |artifact| required << "artifacts/#{artifact.fetch('id')}.zip" }
    end
    missing = required - manifest.fetch("files").keys
    complete = manifest.fetch("state") == "complete" && manifest.fetch("gaps").empty? && missing.empty? && errors.empty?
    raise BenchmarkCases::Error, errors.join("\n") unless errors.empty?
    {"repository" => manifest.fetch("repository"), "run_id" => manifest.fetch("run_id"), "state" => complete ? "complete" : "partial",
     "verified_files" => manifest.fetch("files").length, "gaps" => manifest.fetch("gaps"), "missing_files" => missing}
  end
end
