# frozen_string_literal: true

require_relative "benchmark-cadence"
require_relative "source-promotion"
require "digest"

# Retain the monitor's receipts and canonical observations, including missing,
# pending and failed work. Website publication remains a separate review.
module PublishCurrent
  class Publisher < SourcePromotion::Publisher
    def verify_expected(head, expected)
      tree = api("repos/#{repository}/git/trees/#{head}?recursive=1")
      raise BenchmarkCases::Error, "Cannot verify a truncated observation tree" if tree["truncated"]
      blobs = tree.fetch("tree").select { |entry| entry["type"] == "blob" }.to_h { |entry| [entry.fetch("path"), entry.fetch("sha")] }
      expected.each do |path, content|
        sha = content && Digest::SHA1.hexdigest("blob #{content.bytesize}\0#{content}")
        raise BenchmarkCases::Error, "#{path} changed during observation publication" unless blobs[path] == sha
      end
    end
  end

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
    end.uniq
    {"schema_version" => 1, "repository" => BenchmarkCases::REPOSITORY, "generated_at" => Time.now.utc.iso8601,
      "cli_selection" => BenchmarkCLI.selection(root: root), "publication" => "unreviewed",
      "scope" => "Central scheduled and rolling receipts; original phase artifacts remain authoritative",
      "monitor_files" => files.to_h { |path| [File.basename(path), Digest::SHA256.file(path).hexdigest] },
      "outcomes" => outcomes, "records" => records,
      "storage_measured_count" => records.count { |record| !record.dig("cache", "storage_bytes").nil? },
      "storage_unmeasured_count" => records.count { |record| record.dig("cache", "storage_bytes").nil? }}
  end

  def self.retain(current, directory:)
    current.fetch("outcomes").each do |cadence, outcome|
      groups = Array(outcome["repositories"]).flat_map { |repo| Array(repo.dig("dispatch", "runs")) } +
        Array(outcome["cases"]).flat_map { |item| Array(item["runs"]) }
      groups.group_by { |run| run["id"] }.each_value do |members|
        run = members.first
        next unless run["id"].is_a?(Integer) && run["id"].positive?
        BenchmarkCases.write_json(File.join(directory, cadence, "#{run.fetch('id')}.json"),
          {"schema_version" => 1, "cadence" => cadence, "collected_at" => outcome.fetch("collected_at"), "run" => run,
            **(members.length > 1 ? {"case_records" => members} : {})})
      end
    end
  end

  def self.commit(root: BenchmarkCases::ROOT, publisher: nil)
    publisher ||= Publisher.new(root: root)
    tracked = BenchmarkCases.command("git", "ls-tree", "-r", "--name-only", "HEAD", "--",
      "data/latest", "data/observations", chdir: root).lines.map(&:strip)
    changes, expected = {}, {}
    Dir[File.join(root, "data/latest/*.json"), File.join(root, "data/observations/**/*.json")].sort.each do |path|
      raise BenchmarkCases::Error, "Observation publication requires regular files" if File.symlink?(path) || !File.file?(path)
      relative = path.delete_prefix("#{root}/")
      original = tracked.include?(relative) ? BenchmarkCases.command("git", "show", "HEAD:#{relative}", chdir: root) : nil
      content = File.read(path)
      next if content == original
      changes[relative] = content
      expected[relative] = original
    end
    return nil if changes.empty?
    publisher.commit(changes, expected: expected, message: "data: refresh benchmark index")
  end
end

if $PROGRAM_NAME == __FILE__
  options = {}
  OptionParser.new do |parser|
    parser.on("--commit") { options[:commit] = true }
    parser.on("--input DIRECTORY") { |value| options[:input] = value }
    parser.on("--history DIRECTORY") { |value| options[:history] = value }
    parser.on("--output PATH") { |value| options[:output] = value }
  end.parse!
  if options[:commit]
    puts(PublishCurrent.commit || "No index changes detected")
    exit
  end
  current = PublishCurrent.build(options.fetch(:input))
  BenchmarkCases.write_json(options.fetch(:output), current)
  PublishCurrent.retain(current, directory: options.fetch(:history)) if options[:history]
end
