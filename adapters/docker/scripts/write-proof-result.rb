#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "benchmark-report"
required = lambda { |name| value = ENV.fetch(name); raise "#{name} is required" if value.strip.empty?; value }
phase = required.call("PHASE")
lane = required.call("CACHE_LANE")
BenchmarkReport.phase({"benchmark" => required.call("CASE_ID"), "strategy" => "boringcache", "variant" => required.call("CLI_PLATFORM"),
  "lane" => lane, "phase" => lane == "rolling" ? "commit" : phase == "publish" ? "cold" : "warm", "mode" => "docker",
  "source_repository" => required.call("SOURCE_REPOSITORY"), "source_sha" => required.call("SOURCE_SHA"),
  "build_seconds" => Float(required.call("BUILD_SECONDS")), "restore_or_setup_seconds" => 0, "verification_passed" => true,
  "cache_tag" => required.call("CACHE_SCOPE"), "evidence" => required.call("EVIDENCE_PATH"), "output_dir" => "benchmark-results"})
