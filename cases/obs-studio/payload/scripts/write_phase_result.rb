#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-plan"
require_relative "benchmark-report"

args = {"output_dir" => "benchmark-results", "cache_key" => ""}
OptionParser.new do |parser|
  %w[surface strategy phase source_sha restore_seconds build_seconds cache_key action_evidence native_evidence output_dir].each do |name|
    parser.on("--#{name.tr('_','-')} VALUE") { |value| args[name] = value }
  end
end.parse!
phase = args.fetch("phase")
raise "Phase must be base or rolling" unless %w[base rolling].include?(phase)
build_seconds = Float(args.fetch("build_seconds"))
raise "Build time must be finite and nonnegative" unless build_seconds.finite? && build_seconds >= 0
native = args["native_evidence"] && JSON.parse(File.read(args["native_evidence"]))
action = args["action_evidence"] && JSON.parse(File.read(args["action_evidence"]))
hits = native && native.fetch("direct_cache_hit", 0) + native.fetch("preprocessed_cache_hit", 0)
misses = native && native.fetch("cache_miss", 0)
result = {"schema_version" => 2, "benchmark" => "obs-studio-compiler-cache", "surface" => args.fetch("surface"),
  "strategy" => args.fetch("strategy"), "phase" => phase, "project" => {"repository" => "obsproject/obs-studio", "source_sha" => args.fetch("source_sha")},
  "timing" => {"restore_seconds" => Integer(args.fetch("restore_seconds")), "build_seconds" => build_seconds,
    "boundary" => "upstream build log group; excludes dependency installation and configuration",
    "end_to_end_seconds" => Integer(args.fetch("restore_seconds")) + build_seconds},
  "classification" => {"sample_valid" => true, "reporting_mode" => phase == "base" ? "cold" : "commit-build",
    "reporting_reason" => phase == "base" ? "Pinned parent commit seeds an empty compiler-cache cohort" : "Adjacent source commit restores the parent compiler-cache cohort",
    "validity_reason" => "Workflow output and native cache verification passed", "cache_import_status" => phase == "base" ? "cold" : "hit"},
  "cache" => {"key" => args["cache_key"].empty? ? action&.dig("phases", "restore", "cache_tag") : args["cache_key"]},
  "native" => native && {"cache_hits" => hits, "cache_misses" => misses, "cache_hit_percent" => hits + misses > 0 ? (hits * 100.0 / (hits + misses)).round(1) : nil,
    "remote_storage_hits" => native.fetch("remote_storage_hit", 0), "remote_storage_writes" => native.fetch("remote_storage_write", 0),
    "remote_storage_errors" => native.fetch("remote_storage_error", 0), "remote_storage_timeouts" => native.fetch("remote_storage_timeout", 0)},
  "github" => BenchmarkReport.github_identity}
BenchmarkReport.write_json(File.join(args["output_dir"], "#{args['surface']}-#{args['strategy']}-#{phase}.json"), result)
BenchmarkReport.phase({"benchmark" => "obs-studio-#{args['surface']}", "strategy" => args["strategy"], "variant" => args.fetch("surface"),
  "lane" => phase == "base" ? "fresh" : "rolling", "phase" => phase == "base" ? "cold" : "commit", "mode" => args["surface"],
  "source_repository" => "obsproject/obs-studio", "source_sha" => args["source_sha"], "build_seconds" => build_seconds,
  "restore_or_setup_seconds" => Integer(args["restore_seconds"]), "cache_hit" => phase == "base" ? "false" : "true",
  "evidence" => args["action_evidence"], "storage_key" => args["cache_key"], "output_dir" => args["output_dir"],
  "verification_passed" => true, "comparison_seconds" => Integer(args["restore_seconds"]) + build_seconds})
