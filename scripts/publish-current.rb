# frozen_string_literal: true

require_relative "benchmark-cadence"
require "digest"

# Retain the monitor's receipts and canonical observations, including missing,
# pending and failed work. Website publication remains a separate review.
module PublishCurrent
  def self.build(directory, root: BenchmarkCases::ROOT)
    files = Dir[File.join(directory, "benchmark-outcomes-*.json")].sort
    raise BenchmarkCases::Error, "No central monitor outcomes were retained" if files.empty?
    outcomes = files.to_h { |path| [File.basename(path, ".json").delete_prefix("benchmark-outcomes-"), JSON.parse(File.read(path))] }
    raise BenchmarkCases::Error, "The monitor did not retain every cadence" unless (outcomes.keys & %w[daily weekly rolling]).sort == %w[daily rolling weekly]
    records = outcomes.values.flat_map do |outcome|
      fresh = Array(outcome["repositories"]).flat_map { |repo| Array(repo.dig("dispatch", "runs")) }
        .flat_map { |run| Array(run["observations"]).filter_map { |observation| observation["phase_record"] } }
      rolling = Array(outcome["cases"]).flat_map { |item| Array(item["runs"]) }.flat_map { |run| Array(run["canonical_records"]) }
      fresh + rolling
    end
    {"schema_version" => 1, "repository" => BenchmarkCases::REPOSITORY, "generated_at" => Time.now.utc.iso8601,
      "cli_selection" => BenchmarkCLI.selection(root: root), "publication" => "unreviewed",
      "scope" => "Central scheduled and rolling receipts; original phase artifacts remain authoritative",
      "monitor_files" => files.to_h { |path| [File.basename(path), Digest::SHA256.file(path).hexdigest] },
      "outcomes" => outcomes, "records" => records,
      "storage_measured_count" => records.count { |record| !record.dig("cache", "storage_bytes").nil? },
      "storage_unmeasured_count" => records.count { |record| record.dig("cache", "storage_bytes").nil? }}
  end
end

if $PROGRAM_NAME == __FILE__
  options = {}
  OptionParser.new do |parser|
    parser.on("--input DIRECTORY") { |value| options[:input] = value }
    parser.on("--output PATH") { |value| options[:output] = value }
  end.parse!
  BenchmarkCases.write_json(options.fetch(:output), PublishCurrent.build(options.fetch(:input)))
end
