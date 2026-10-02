#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"
require_relative "benchmark-report"
args = {}
OptionParser.new do |parser|
  parser.on("--input-dir PATH") { |value| args["input_dir"] = value }
  parser.on("--output-dir PATH") { |value| args["output_dir"] = value }
end.parse!
results = %w[actions-cache boringcache].to_h do |strategy|
  paths = Dir[File.join(args.fetch("input_dir"), "**", "continuation-#{strategy}.json")]
  raise "Expected one #{strategy} continuation result, found #{paths.length}" unless paths.length == 1
  payload = JSON.parse(File.read(paths.first))
  raise "#{strategy} continuation sample is invalid" unless payload.dig("classification", "sample_valid") == true
  [strategy, payload]
end
before, after = results.values_at("actions-cache", "boringcache")
raise "Continuation results use different generations or source commits" unless before.values_at("generation", "project") == after.values_at("generation", "project")
baseline = before.dig("timing", "restore_and_build_seconds")
candidate = after.dig("timing", "restore_and_build_seconds")
payload = {"schema_version" => 1, "benchmark" => "obs-studio-xcode-continuation", "generation" => before["generation"], "project" => before["project"],
  "sample_valid" => true, "results" => results, "comparison" => {"actions_cache_restore_and_build_seconds" => baseline,
    "boringcache_restore_and_build_seconds" => candidate, "boringcache_seconds_saved" => baseline - candidate}}
BenchmarkReport.write_json(File.join(args.fetch("output_dir"), "continuation-comparison.json"), payload)
lines = ["## OBS Xcode continuation generation #{before['generation']}", "", "| Provider | Restore | Build | Restore + build | Save | Local bytes before | Local bytes after |",
  "| --- | ---: | ---: | ---: | ---: | ---: | ---: |"]
results.each do |strategy, result|
  timing, cache = result.values_at("timing", "cache")
  lines << "| #{strategy} | #{timing['restore_seconds']}s | #{timing['build_seconds']}s | #{timing['restore_and_build_seconds']}s | #{timing['save_seconds']}s | #{cache['bytes_before']} | #{cache['bytes_after']} |"
end
lines += ["", "Individual matched measurements; performance claims require a reviewed series. Local directory bytes are not remote retained storage.", ""]
File.write(File.join(args.fetch("output_dir"), "continuation-comparison.md"), lines.join("\n"))
