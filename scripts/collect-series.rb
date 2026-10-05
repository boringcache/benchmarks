# frozen_string_literal: true

require_relative "benchmark-series"
require_relative "benchmark-evidence"

module CollectSeries
  def self.call(directory, evidence_directory:, sample:)
    plan = BenchmarkSeries.load(directory)
    verified = BenchmarkEvidence.verify(evidence_directory)
    raise BenchmarkSeries::Error, "Collection requires a complete verified evidence export" unless verified["state"] == "complete"
    run_id = verified.fetch("run_id").to_s
    receipts = Dir[File.join(directory, "dispatches", "*.json")].map { |path| JSON.parse(File.read(path)) }
    receipts.select! do |receipt|
      plan.fetch("workflow_inputs").all? { |key, value| receipt.dig("inputs", key) == value }
    end
    unless receipts.any? { |receipt| receipt["run_id"].to_s == run_id && receipt["repository"] == verified["repository"] && receipt["case_id"] == plan["case_id"] && receipt.dig("inputs", "series_id") == plan["series_id"] && receipt.dig("inputs", "sample").to_s == sample.to_s }
      raise BenchmarkSeries::Error, "Evidence does not match a retained dispatch for this sample"
    end

    manifest = JSON.parse(File.read(File.join(evidence_directory, "manifest.json")))
    records = {}
    manifest.fetch("artifacts").each do |artifact|
      archive = File.join(evidence_directory, "artifacts", "#{artifact.fetch('id')}.zip")
      names, error, status = Open3.capture3("unzip", "-Z1", archive)
      raise BenchmarkSeries::Error, "Cannot list phase artifact: #{error.strip}" unless status.success?
      names.lines.map(&:strip).grep(/\.json\z/).each do |name|
        # Proof bundles also contain raw product evidence. Only collect canonical
        # phase filenames or the contents of a dedicated phase artifact.
        next unless artifact.fetch("name").start_with?("phase-") || name.match?(/-(?:fresh-(?:cold|warm)|rolling-commit)\.json\z/)
        value = JSON.parse(read_record(archive, name))
        BenchmarkSeries.validate_record(plan, value)
        unless value.dig("github", "run_id").to_s == run_id && value.dig("series", "sample") == sample
          raise BenchmarkSeries::Error, "Phase artifact belongs to another run or sample"
        end
        target = File.join(directory, "runs", "#{sample}-#{value.fetch('strategy')}-#{value.fetch('phase')}.json")
        existing = records[target] || (JSON.parse(File.read(target)) if File.exist?(target))
        raise BenchmarkSeries::Error, "Conflicting records for the same observation" if existing && existing != value
        records[target] = value
      end
    end
    completion_path = File.join(directory, "completions", "#{run_id}.json")
    if File.exist?(completion_path)
      completion = JSON.parse(File.read(completion_path))
      unless completion["sample"] == sample && completion["evidence_manifest_sha256"] == Digest::SHA256.file(File.join(evidence_directory, "manifest.json")).hexdigest
        raise BenchmarkSeries::Error, "This run has a different completion record"
      end
    end
    records.each { |path, value| BenchmarkSeries.write_json(path, value) unless File.exist?(path) }
    completion ||= BenchmarkSeries.finish(directory, evidence_directory: evidence_directory, sample: sample)
    BenchmarkSeries.report(directory)
    {"records" => records.length, "completion" => completion}
  end

  def self.read_record(archive, name)
    unless name.match?(%r{\A[a-zA-Z0-9_./-]+\.json\z}) && !name.start_with?("/") && !name.split("/").include?("..")
      raise BenchmarkSeries::Error, "Unsafe phase artifact filename"
    end
    Open3.popen3("unzip", "-p", archive, name) do |input, output, error, process|
      input.close
      content = output.read(8 * 1024 * 1024 + 1)
      if content.bytesize > 8 * 1024 * 1024
        Process.kill("TERM", process.pid)
        raise BenchmarkSeries::Error, "Phase record exceeds 8 MiB"
      end
      raise BenchmarkSeries::Error, "Cannot read phase artifact: #{error.read.strip}" unless process.value.success?
      content
    end
  end
end
