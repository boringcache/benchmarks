#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"
require_relative "benchmark-report"
args = {"output_dir" => "benchmark-results", "save_seconds" => 0, "cache_bytes_before" => 0, "cache_bytes_after" => 0}
OptionParser.new do |parser|
  %w[strategy parent_sha source_sha restore_key save_key native_evidence output_dir].each do |name|
    parser.on("--#{name.tr('_','-')} VALUE") { |value| args[name] = value }
  end
  %w[generation restore_seconds build_seconds save_seconds cache_bytes_before cache_bytes_after].each do |name|
    parser.on("--#{name.tr('_','-')} VALUE", Integer) { |value| raise "#{name} must be nonnegative" if value < 0; args[name] = value }
  end
end.parse!
timing = args.slice("restore_seconds", "build_seconds", "save_seconds")
timing["restore_and_build_seconds"] = args.fetch("restore_seconds") + args.fetch("build_seconds")
timing["end_to_end_seconds"] = timing["restore_and_build_seconds"] + args["save_seconds"]
payload = {"schema_version" => 1, "benchmark" => "obs-studio-xcode-continuation", "surface" => "xcode", "strategy" => args.fetch("strategy"),
  "generation" => args.fetch("generation"), "project" => {"repository" => "obsproject/obs-studio", "parent_sha" => args.fetch("parent_sha"), "source_sha" => args.fetch("source_sha")},
  "timing" => timing, "cache" => {"restore_key" => args.fetch("restore_key"), "save_key" => args.fetch("save_key"),
    "bytes_before" => args["cache_bytes_before"], "bytes_after" => args["cache_bytes_after"], "growth_bytes" => [0, args["cache_bytes_after"] - args["cache_bytes_before"]].max},
  "native" => args["native_evidence"] && JSON.parse(File.read(args["native_evidence"])),
  "classification" => {"sample_valid" => true, "reporting_mode" => "continuation", "cache_import_status" => "hit", "reporting_reason" => "Fresh runner restored the previous generation and built its exact child commit"},
  "github" => BenchmarkReport.github_identity}
BenchmarkReport.write_json(File.join(args["output_dir"], "continuation-#{args['strategy']}.json"), payload)
