# frozen_string_literal: true

require_relative "benchmark-cadence"
require_relative "source-promotion"
require "digest"

# Retain the monitor's receipts and canonical observations, including missing,
# pending and failed work. Website publication remains a separate review.
module PublishCurrent
  class Publisher < SourcePromotion::Publisher
    def commit(changes, expected:, message:)
      unless changes.keys.all? { |path| path.match?(%r{\Adata/(?:latest|observations)/[a-zA-Z0-9_./-]+\.json\z}) && !path.split("/").include?("..") } && (changes.keys - expected.keys).empty?
        raise SourcePromotion::Error, "Index publication requires protected data files"
      end
      blobs = nil
      20.times do
        head = api("repos/#{repository}/git/ref/heads/#{branch}").dig("object", "sha")
        verify_expected(head, expected)
        blobs ||= changes.map do |path, contents|
          blob = api("repos/#{repository}/git/blobs", body: {"content" => Base64.strict_encode64(contents), "encoding" => "base64"})
          {"path" => path, "mode" => "100644", "type" => "blob", "sha" => blob.fetch("sha")}
        end
        base = api("repos/#{repository}/git/commits/#{head}").dig("tree", "sha")
        tree = api("repos/#{repository}/git/trees", body: {"base_tree" => base, "tree" => blobs})
        created = api("repos/#{repository}/git/commits", body: {"message" => message, "tree" => tree.fetch("sha"), "parents" => [head]})
        return created.fetch("sha") if advance_ref(created.fetch("sha"))
        current = api("repos/#{repository}/git/ref/heads/#{branch}").dig("object", "sha")
        raise SourcePromotion::Error, "Index reference update was rejected" if current == head
      end
      raise SourcePromotion::Error, "Index publication could not acquire the current branch head"
    end

    def advance_ref(sha)
      output, error, status = Open3.capture3("gh", "api", "repos/#{repository}/git/refs/heads/#{branch}",
        "--method", "PATCH", "--input", "-", stdin_data: JSON.generate({"sha" => sha, "force" => false}))
      if status.success?
        raise SourcePromotion::Error, "Index reference response differs from the requested commit" unless JSON.parse(output).dig("object", "sha") == sha
        return true
      end
      rejected = JSON.parse(output) rescue {}
      return false if error.include?("HTTP 422") && rejected["message"] == "Update is not a fast forward"
      current = api("repos/#{repository}/git/ref/heads/#{branch}").dig("object", "sha")
      return true if current == sha
      raise SourcePromotion::Error, "GitHub index reference update failed: #{error.strip}"
    end

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
