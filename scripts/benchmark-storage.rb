# frozen_string_literal: true

require "json"
require "time"
require_relative(File.file?(File.join(__dir__, "benchmark-report.rb")) ? "benchmark-report" : "canonical/benchmark-report")

module BenchmarkStorage
  def self.measure(evidence, evidence_file:)
    restore = evidence.fetch("phases").fetch("restore")
    identity = BenchmarkReport.identity({}, restore)
    value = BenchmarkReport.boringcache_storage(identity)
    {"schema_version" => 1, "kind" => "post-publication-storage", "observed_at" => Time.now.utc.iso8601,
      "github" => BenchmarkReport.github_identity, "evidence_file" => File.basename(evidence_file),
      "identity" => identity, "measurement" => value,
      "state" => value && value["bytes"] ? "measured" : "unmeasured"}
  end

  def self.apply(record, measurements)
    tags = Array(record.dig("action", "resolved_tags"))
    return record if tags.empty?
    matches = measurements.select do |value|
      value["kind"] == "post-publication-storage" &&
        value.dig("github", "run_id").to_s == record.dig("github", "run_id").to_s &&
        value.dig("github", "run_attempt").to_s == record.dig("github", "run_attempt").to_s &&
        value.dig("identity", "workspace") == record.dig("cache", "workspace") &&
        Array(value.dig("identity", "tags")).sort == tags.sort
    end
    return record if matches.empty?
    latest = matches.max_by { |value| value.fetch("observed_at") }
    storage = latest["measurement"]
    return record unless storage && !storage["bytes"].nil?
    copy = Marshal.load(Marshal.dump(record))
    copy["original_cache_measurement"] = record.fetch("cache").slice("storage_bytes", "storage_source", "storage_breakdown")
    copy["cache"].merge!("storage_bytes" => storage.fetch("bytes"), "storage_source" => storage.fetch("source"),
      "storage_breakdown" => storage.fetch("breakdown"), "storage_observed_at" => latest.fetch("observed_at"),
      "storage_evidence_file" => latest.fetch("evidence_file"))
    copy
  end
end

if $PROGRAM_NAME == __FILE__
  evidence_file, output = ARGV
  abort "Use an original product evidence file and a storage output path" unless evidence_file && output
  value = BenchmarkStorage.measure(JSON.parse(File.read(evidence_file)), evidence_file: evidence_file)
  File.write(output, JSON.pretty_generate(value) + "\n")
end
