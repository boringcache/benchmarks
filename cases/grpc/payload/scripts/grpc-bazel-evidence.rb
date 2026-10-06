# frozen_string_literal: true

require "json"
require "fileutils"

module GrpcBazelEvidence
  def self.read(log)
    summary = log.gsub(/\e\[[0-9;]*m/, "").lines.filter_map do |line|
      line.match(/\AINFO: (\d+) processes?: (.+)\.\s*\z/)
    end.last
    return {"source" => "bazel-process-summary", "hit" => nil, "processes" => nil} unless summary
    counts = summary[2].split(", ").to_h do |part|
      match = part.match(/\A(\d+) (.+)\z/)
      raise "Invalid Bazel process summary" unless match
      [match[2], match[1].to_i]
    end
    raise "Bazel process counts differ from the summary total" unless counts.values.sum == summary[1].to_i
    hits = counts.sum { |name, count| name.match?(/\A(?:remote|disk) cache hits?\z/) ? count : 0 }
    {"source" => "bazel-process-summary", "hit" => hits.positive?, "cache_hit_processes" => hits,
      "processes" => counts, "total_processes" => summary[1].to_i, "summary" => summary[0].strip}
  end
end

if $PROGRAM_NAME == __FILE__
  evidence = GrpcBazelEvidence.read(File.read(ARGV.fetch(0)))
  FileUtils.mkdir_p("benchmark-results/bazel")
  File.write("benchmark-results/bazel/cache-evidence.json", JSON.pretty_generate(evidence) + "\n")
  if ENV["GITHUB_OUTPUT"]
    File.open(ENV.fetch("GITHUB_OUTPUT"), "a") { |file| file.puts("cache_hit=#{evidence['hit']}") }
  end
  abort "Bazel warm build did not report native cache reuse" if ENV["PHASE"] == "warm" && evidence["hit"] != true
end
